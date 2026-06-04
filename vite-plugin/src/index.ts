import type { Plugin, ViteDevServer, WatchOptions } from 'vite';
import { spawnSync } from 'child_process';
import fs from 'fs';
import os from 'os';
import path from 'path';

type BuildMode = 'debug' | 'release';

type JsOutput = {
  jsPath: string;
  sourceMapPath?: string;
};

type RabbitaOptions = {
  mainPkgDir?: string;
  /** @deprecated Use mainPkgDir instead. */
  main?: string;
  /** @deprecated Use mainPkgDir instead. */
  moonModDir?: string;
};

const VIRTUAL_MAIN_ENTRY_ID = '\0rabbita:main-entry';
const WATCH_IGNORED_DIRS = ['**/.mooncakes/**', '**/_build/**'];

function normalizePathLike(input: string): string {
  return input.replaceAll('\\', '/').replace(/^\/+|\/+$/g, '');
}

function findJsOutputs(buildDir: string, selector?: string): Array<string> {
  if (!fs.existsSync(buildDir)) {
    return [];
  }

  const run = (args: Array<string>) => {
    const result = spawnSync('find', [buildDir, ...args, '-print0'], { encoding: 'utf8' });
    if (result.error) {
      throw result.error;
    }
    if (result.status !== 0) {
      throw new Error((result.stdout ?? '') + (result.stderr ?? ''));
    }
    return result.stdout.split('\0').filter(Boolean);
  };
  const sort = (files: Array<string>) => [...new Set(files)].sort((a, b) => {
    const relA = normalizePathLike(path.relative(buildDir, a));
    const relB = normalizePathLike(path.relative(buildDir, b));
    const depthDiff = relA.split('/').length - relB.split('/').length;
    return depthDiff === 0 ? relA.localeCompare(relB) : depthDiff;
  });
  const baseArgs = ['-path', '*/.mooncakes', '-prune', '-o', '-type', 'f'];

  if (!selector) {
    return sort(run([...baseArgs, '-name', '*.js']));
  }

  const expected = normalizePathLike(selector.endsWith('.js') ? selector.slice(0, -3) : selector);
  const escapeGlob = (input: string) => input.replace(/[\\*?[\]]/g, '\\$&');
  if (expected === '') {
    return [];
  }
  const escaped = escapeGlob(expected);
  const escapedBase = escapeGlob(path.posix.basename(expected));
  const patterns = [
    `*/${escaped}/${escapedBase}.js`,
    `*/${escaped}.js`,
  ];

  for (const pattern of patterns) {
    const matched = sort(run([...baseArgs, '-path', pattern]));
    if (matched.length > 0) {
      return matched;
    }
  }

  return [];
}

function findJsOutput(
  buildDir: string,
  preferredPackagePath?: string,
  isMainPkgDirBuild = false,
): JsOutput | undefined {
  if (!fs.existsSync(buildDir)) {
    return undefined;
  }
  const discovered = findJsOutputs(buildDir);

  if (preferredPackagePath) {
    let matched = findJsOutputs(buildDir, preferredPackagePath);
    if (matched.length === 0) {
      const parts = normalizePathLike(preferredPackagePath).split('/').filter(Boolean);
      if (parts.length > 2) {
        matched = findJsOutputs(buildDir, parts.slice(2).join('/'));
      }
    }
    if (matched.length > 1) {
      throw new Error(
        `Multiple JS outputs match main "${preferredPackagePath}": `
        + matched.map(file => `"${path.relative(buildDir, file)}"`).join(', '),
      );
    }
    if (matched.length === 0) {
      throw new Error(
        `Cannot locate generated JS output for main "${preferredPackagePath}" under "${buildDir}".`
        + (discovered.length > 0
          ? ` Available JS outputs: ${discovered.map(file => `"${path.relative(buildDir, file)}"`).join(', ')}.`
          : ''),
      );
    }
    const mapPath = `${matched[0]}.map`;
    return {
      jsPath: matched[0],
      sourceMapPath: fs.existsSync(mapPath) ? mapPath : undefined,
    };
  }

  if (discovered.length === 0) {
    return undefined;
  }
  if (discovered.length > 1) {
    throw new Error(
      isMainPkgDirBuild
        ? `Multiple JS outputs generated under "${buildDir}" after building mainPkgDir. `
        + discovered.map(file => `"${path.relative(buildDir, file)}"`).join(', ')
        : `Multiple JS outputs generated under "${buildDir}". `
        + 'Pass rabbita({ mainPkgDir: ... }) to select one: '
        + discovered.map(file => `"${path.relative(buildDir, file)}"`).join(', '),
    );
  }

  const mapPath = `${discovered[0]}.map`;
  return {
    jsPath: discovered[0],
    sourceMapPath: fs.existsSync(mapPath) ? mapPath : undefined,
  };
}

function runMoonBuild(mode: BuildMode, cwd: string, targetDir: string, packagePath?: string): void {
  fs.rmSync(targetDir, { recursive: true, force: true });
  fs.mkdirSync(targetDir, { recursive: true });
  const args = [
    'build',
    ...(packagePath ? [packagePath] : []),
    '--target',
    'js',
    '--target-dir',
    targetDir,
    mode === 'release' ? '--release' : '--debug',
  ];
  const result = spawnSync('moon', args, { cwd, encoding: 'utf8' });
  if (result.status === 0) {
    return;
  }
  if (result.error) {
    throw result.error;
  }
  throw new Error((result.stdout ?? '') + (result.stderr ?? ''));
}

function shouldRebuildForFile(filePath: string): boolean {
  const normalizedPath = filePath.replaceAll('\\', '/');
  const pathParts = normalizedPath.split('/');
  if (pathParts.includes('.mooncakes')
    || pathParts.includes('_build')
    || pathParts.includes('node_modules')
    || pathParts.includes('dist')) {
    return false;
  }

  return normalizedPath.endsWith('.mbt')
    || normalizedPath.endsWith('.mbtp')
    || normalizedPath.endsWith('.mbti')
    || normalizedPath.endsWith('moon.mod.json')
    || normalizedPath.endsWith('moon.pkg.json')
    || normalizedPath.endsWith('moon.work')
    || normalizedPath.endsWith('moon.mod')
    || normalizedPath.endsWith('moon.pkg')
    || normalizedPath.endsWith('.js')
    || normalizedPath.endsWith('.css')
    || normalizedPath.endsWith('.html')
}

function resolveInsideConfigDir(configDir: string, value: string, optionName: string): string {
  const resolved = path.resolve(configDir, value);
  assertInsideDirectory(configDir, resolved, `${optionName} must point inside the Vite config directory`);
  return resolved;
}

function assertInsideDirectory(parentDir: string, childPath: string, message: string): void {
  const parent = path.resolve(parentDir);
  const child = path.resolve(childPath);
  if (parent === child) {
    return;
  }
  const relative = path.relative(parent, child);
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    throw new Error(`${message}: "${child}"`);
  }
}

/**
 * Rabbita Vite plugin.
 *
 * Config:
 * - `mainPkgDir`:
 *   Optional filesystem path to the main package directory, relative to the
 *   Vite config file. The plugin builds it with `moon build .`.
 * - `main` and `moonModDir`:
 *   Deprecated compatibility options.
 *
 * Build behavior:
 * - Uses a plugin-owned MoonBit target directory, so output discovery does not
 *   depend on a workspace or module `_build` location.
 * - `mainPkgDir` builds only that package and requires exactly one
 *   generated JS output.
 *
 * Entry behavior:
 * - Keeps `index.html` unchanged (still supports `/main.js`).
 * - Also accepts the real MoonBit output filename whose basename depends on
 *   the selected main package.
 */
export function rabbita(options: RabbitaOptions = {}): Plugin {
  const mainPkgDir = options.mainPkgDir;
  const legacyMainPackagePath = options.main;
  if (mainPkgDir && (options.main || options.moonModDir)) {
    throw new Error('Do not use mainPkgDir together with deprecated main or moonModDir options.');
  }
  let moonBuildCwd: string | undefined = undefined;
  let isBuild = false;
  let latestOutput: JsOutput | undefined = undefined;
  let latestLoggedJsPath: string | undefined = undefined;
  let rebuildTimer: ReturnType<typeof setTimeout> | undefined = undefined;
  let targetDir: string | undefined = undefined;

  function runMoonbitBuild(): JsOutput {
    if (!moonBuildCwd) {
      throw new Error('Cannot determine MoonBit build directory.');
    }
    const primaryMode: BuildMode = isBuild ? 'release' : 'debug';
    if (!targetDir) {
      targetDir = fs.mkdtempSync(path.join(os.tmpdir(), 'rabbita-vite-'));
    }
    runMoonBuild(primaryMode, moonBuildCwd, targetDir, mainPkgDir ? '.' : undefined);

    const buildDir = path.join(targetDir, 'js', primaryMode, 'build');
    const output = findJsOutput(
      buildDir,
      mainPkgDir ? undefined : legacyMainPackagePath,
      Boolean(mainPkgDir),
    );

    if (!output) {
      throw new Error(
        `Cannot locate generated JS output under "${targetDir}". `
        + 'Please verify your MoonBit main package and build artifacts.',
      );
    }

    const relativeJsPath = normalizePathLike(path.relative(buildDir, output.jsPath));
    if (output.jsPath !== latestLoggedJsPath) {
      const reason = mainPkgDir
        ? `mainPkgDir "${mainPkgDir}"`
        : legacyMainPackagePath
          ? `deprecated main "${legacyMainPackagePath}"`
          : 'unique generated JS output';
      console.log(
        `[vite-plugin-rabbita] selected ${relativeJsPath} (${reason})`,
      );
      latestLoggedJsPath = output.jsPath;
    }

    latestOutput = output;
    return output;
  }

  function ensureOutput(): JsOutput {
    if (
      !latestOutput
      || !fs.existsSync(latestOutput.jsPath)
      || (latestOutput.sourceMapPath && !fs.existsSync(latestOutput.sourceMapPath))
    ) {
      return runMoonbitBuild();
    }
    return latestOutput;
  }

  function reportError(err: string, server: ViteDevServer): void {
    const errMsg = err.split('\n').slice(1).join('\n');
    server.ws.send({
      type: 'error',
      err: {
        message: errMsg,
        stack: '',
        id: 'rabbita-build',
        plugin: 'vite-plugin-rabbita',
      },
    });
  }

  function scheduleRebuild(server: ViteDevServer, filePath: string): void {
    if (!shouldRebuildForFile(filePath)) {
      return;
    }

    if (rebuildTimer) {
      clearTimeout(rebuildTimer);
    }

    rebuildTimer = setTimeout(() => {
      rebuildTimer = undefined;
      try {
        runMoonbitBuild();
        server.moduleGraph.invalidateAll();
        server.ws.send({ type: 'full-reload' });
      } catch (err: any) {
        reportError(err.toString(), server);
      }
    }, 10);
  }

  return {
    name: 'vite-plugin-rabbita',
    enforce: 'pre',

    config(config, { command }) {
      isBuild = command === 'build';
      if (isBuild || config.server?.watch === null) {
        return;
      }

      const watch: WatchOptions = config.server?.watch ?? {};
      const ignored = watch.ignored
        ? Array.isArray(watch.ignored) ? watch.ignored : [watch.ignored]
        : [];

      return {
        server: {
          watch: {
            ...watch,
            ignored: [
              ...ignored,
              ...WATCH_IGNORED_DIRS,
            ],
          },
        },
      };
    },

    configResolved(config) {
      const configDir = typeof config.configFile === 'string' ? path.dirname(config.configFile) : process.cwd();
      if (mainPkgDir) {
        const packageDir = resolveInsideConfigDir(configDir, mainPkgDir, 'mainPkgDir');
        if (!fs.existsSync(packageDir) || !fs.statSync(packageDir).isDirectory()) {
          throw new Error(`mainPkgDir must point to a directory: "${packageDir}"`);
        }
        moonBuildCwd = packageDir;
      } else {
        const buildCwd = options.moonModDir
          ? resolveInsideConfigDir(configDir, options.moonModDir, 'moonModDir')
          : config.root;
        assertInsideDirectory(
          configDir,
          buildCwd,
          'MoonBit build directory must point inside the Vite config directory',
        );
        moonBuildCwd = buildCwd;
      }
    },

    buildStart() {
      try {
        runMoonbitBuild();
      } catch (err: any) {
        console.log('buildStart error', err);
      }
    },

    resolveId(source) {
      const cleanSource = source.split('?', 1)[0];
      let entryFileName = latestOutput ? path.basename(latestOutput.jsPath) : undefined;
      if (cleanSource.endsWith('.js')) {
        try {
          const needsRefresh = !entryFileName
            || (cleanSource !== `/${entryFileName}` && cleanSource !== entryFileName);
          if (needsRefresh) {
            latestOutput = undefined;
          }
          entryFileName = path.basename(ensureOutput().jsPath);
        } catch {
          // buildStart will report build errors
        }
      }

      if (
        cleanSource === '/main.js'
        || cleanSource === 'main.js'
        || (entryFileName && (cleanSource === `/${entryFileName}` || cleanSource === entryFileName))
      ) {
        return VIRTUAL_MAIN_ENTRY_ID;
      }
      return null;
    },

    load(id) {
      if (id !== VIRTUAL_MAIN_ENTRY_ID) {
        return null;
      }

      const output = ensureOutput();
      const code = fs.readFileSync(output.jsPath, 'utf8')
        .replace(/\n?\/\/[#@]\s*sourceMappingURL=.*$/m, '')
        .replace(/\n?\/\*#\s*sourceMappingURL=.*?\*\//m, '');
      const map = output.sourceMapPath && fs.existsSync(output.sourceMapPath)
        ? JSON.parse(fs.readFileSync(output.sourceMapPath, 'utf8'))
        : null;
      return { code, map };
    },

    handleHotUpdate({ server, file, modules }) {
      const logger = server.config.logger
      const relpath = path.relative(process.cwd(), file)
      if (!shouldRebuildForFile(file)) {
        logger.info(`${relpath} changes detected. Skipped.`, {
          clear: true,
          timestamp: true,
        })
        return modules;
      }
      logger.info(`${relpath} changes detected. Reloading...`, {
        clear: true,
        timestamp: true,
      })
      scheduleRebuild(server, file);
      return [];
    },
  };
}

export default rabbita;
