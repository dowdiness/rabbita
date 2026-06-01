import type { Plugin, ViteDevServer } from 'vite';
import { spawnSync } from 'child_process';
import fs from 'fs';
import os from 'os';
import path from 'path';

type MoonProjectConfig = {
  moduleRoot: string;
  modPath: string;
  workspaceRoot?: string;
};

type BuildMode = 'debug' | 'release';

type JsOutput = {
  jsPath: string;
  sourceMapPath?: string;
};

type RabbitaOptions = {
  main?: string;
  moonModDir?: string;
};

const VIRTUAL_MAIN_ENTRY_ID = '\0rabbita:main-entry';

function normalizePathLike(input: string): string {
  return input.replaceAll('\\', '/').replace(/^\/+|\/+$/g, '');
}

function findNearestMoonWork(startDir: string): string | undefined {
  let current = startDir;
  while (true) {
    const workPath = path.join(current, 'moon.work');
    if (fs.existsSync(workPath)) {
      return current;
    }
    const parent = path.dirname(current);
    if (parent === current) {
      return undefined;
    }
    current = parent;
  }
}

function parseMoonModName(content: string, filePath: string): string {
  const match = content.match(/^\s*name\s*=\s*("(?:\\.|[^"\\])*")/m);
  if (!match) {
    throw new Error(`Field "name" is missing in ${filePath}`);
  }

  try {
    return JSON.parse(match[1]) as string;
  } catch (err: any) {
    throw new Error(`Cannot parse field "name" in ${filePath}: ${err.message}`);
  }
}

function readMoonBitProject(moduleRoot: string): MoonProjectConfig {
  const modFilePath = path.join(moduleRoot, 'moon.mod');
  const modJsonPath = path.join(moduleRoot, 'moon.mod.json');
  if (fs.existsSync(modFilePath)) {
    return {
      moduleRoot,
      modPath: parseMoonModName(fs.readFileSync(modFilePath, 'utf8'), modFilePath),
      workspaceRoot: findNearestMoonWork(moduleRoot),
    };
  }

  if (!fs.existsSync(modJsonPath)) {
    throw new Error(`Cannot find moon.mod or moon.mod.json in ${moduleRoot}`);
  }

  const json = JSON.parse(fs.readFileSync(modJsonPath, 'utf8')) as { name?: string };
  if (!json.name) {
    throw new Error(`Field "name" is missing in ${modJsonPath}`);
  }

  return {
    moduleRoot,
    modPath: json.name,
    workspaceRoot: findNearestMoonWork(moduleRoot),
  };
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
    `*${escaped}*.js`,
    `*/${escapedBase}/${escapedBase}.js`,
    `*/${escapedBase}.js`,
  ];

  for (const pattern of patterns) {
    const matched = sort(run([...baseArgs, '-path', pattern]));
    if (matched.length > 0) {
      return matched;
    }
  }

  return [];
}

function toJsOutput(jsPath: string): JsOutput {
  const mapPath = `${jsPath}.map`;
  return {
    jsPath,
    sourceMapPath: fs.existsSync(mapPath) ? mapPath : undefined,
  };
}

function findJsOutputInTargetDir(
  targetDir: string,
  mode: BuildMode,
  project: MoonProjectConfig,
  preferredPackagePath?: string,
  requestedEntry?: string,
): JsOutput | undefined {
  const buildDir = path.join(targetDir, 'js', mode, 'build');
  if (!fs.existsSync(buildDir)) {
    return undefined;
  }
  const discovered = findJsOutputs(buildDir);
  if (discovered.length === 0) {
    return undefined;
  }

  if (preferredPackagePath) {
    const matched = findJsOutputs(buildDir, preferredPackagePath);
    if (matched.length === 1) {
      return toJsOutput(matched[0]);
    }
    if (matched.length > 1) {
      throw new Error(
        `Multiple JS outputs match main "${preferredPackagePath}": `
        + matched.map(file => `"${path.relative(buildDir, file)}"`).join(', '),
      );
    }
    throw new Error(
      `Cannot locate generated JS output for main "${preferredPackagePath}" under "${buildDir}".`,
    );
  }

  if (requestedEntry) {
    const requestedMatches = findJsOutputs(buildDir, requestedEntry);
    if (requestedMatches.length === 1) {
      return toJsOutput(requestedMatches[0]);
    }
    if (requestedMatches.length > 1) {
      const moduleMatches = new Set(findJsOutputs(buildDir, project.modPath));
      const ownModuleMatches = requestedMatches.filter(file => moduleMatches.has(file));
      if (ownModuleMatches.length === 1) {
        return toJsOutput(ownModuleMatches[0]);
      }
    }
  }

  const ownModuleMatches = findJsOutputs(buildDir, project.modPath);
  if (ownModuleMatches.length === 1) {
    return toJsOutput(ownModuleMatches[0]);
  }

  const moduleNameMatches = findJsOutputs(buildDir, path.posix.basename(normalizePathLike(project.modPath)));
  if (moduleNameMatches.length === 1) {
    return toJsOutput(moduleNameMatches[0]);
  }

  return toJsOutput(discovered[0]);
}

function runMoonBuild(mode: BuildMode, cwd: string, targetDir: string): void {
  fs.rmSync(targetDir, { recursive: true, force: true });
  fs.mkdirSync(targetDir, { recursive: true });
  const args = [
    'build',
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
  const fileName = path.basename(filePath);
  return filePath.endsWith('.mbt')
    || filePath.endsWith('.mbti')
    || fileName === 'moon.work'
    || fileName === 'moon.mod'
    || fileName === 'moon.mod.json'
    || fileName === 'moon.pkg'
    || fileName === 'moon.pkg.json';
}

/**
 * Rabbita Vite plugin.
 *
 * Config:
 * - `main`:
 *   Optional MoonBit package namespace or path-like selector for the main
 *   package (for example: `"test/app/main"` or `"app/web"`).
 *
 * Build behavior:
 * - Uses a plugin-owned MoonBit target directory, so output discovery never
 *   depends on a workspace or module `_build` location.
 * - Selects JS output by `main`, by the requested script filename, then by the
 *   current module namespace.
 *
 * Entry behavior:
 * - Keeps `index.html` unchanged (still supports `/main.js`).
 * - Also accepts the real MoonBit output filename whose basename depends on
 *   the selected main package.
 */
export function rabbita(options: RabbitaOptions = {}): Plugin {
  const mainPackagePath = options.main;
  const explicitMoonModDir = options.moonModDir
    ? path.resolve(options.moonModDir)
    : undefined;
  let project: MoonProjectConfig | undefined = undefined;
  let isBuild = false;
  let latestOutput: JsOutput | undefined = undefined;
  let rebuildTimer: ReturnType<typeof setTimeout> | undefined = undefined;
  let targetDir: string | undefined = undefined;

  function ensureProject(root: string = process.env.INIT_CWD ?? process.cwd()): MoonProjectConfig {
    const moduleRoot = explicitMoonModDir ?? root;
    if (!project || project.moduleRoot !== moduleRoot) {
      project = readMoonBitProject(moduleRoot);
    }
    return project;
  }

  function ensureTargetDir(): string {
    if (!targetDir) {
      targetDir = fs.mkdtempSync(path.join(os.tmpdir(), 'rabbita-vite-'));
    }
    return targetDir;
  }

  function runMoonbitBuild(requestedEntry?: string): JsOutput {
    const currentProject = project ?? ensureProject();
    const primaryMode: BuildMode = isBuild ? 'release' : 'debug';
    const currentTargetDir = ensureTargetDir();
    runMoonBuild(primaryMode, currentProject.moduleRoot, currentTargetDir);

    let output = findJsOutputInTargetDir(
      currentTargetDir,
      primaryMode,
      currentProject,
      mainPackagePath,
      requestedEntry,
    );

    if (!output && primaryMode === 'release') {
      runMoonBuild('debug', currentProject.moduleRoot, currentTargetDir);
      output = findJsOutputInTargetDir(
        currentTargetDir,
        'debug',
        currentProject,
        mainPackagePath,
        requestedEntry,
      );
    }

    if (!output) {
      throw new Error(
        `Cannot locate generated JS output under "${currentTargetDir}". `
        + 'Please verify your MoonBit main package and build artifacts.',
      );
    }

    latestOutput = output;
    return output;
  }

  function ensureOutput(requestedEntry?: string): JsOutput {
    if (!latestOutput) {
      return runMoonbitBuild(requestedEntry);
    }
    if (!fs.existsSync(latestOutput.jsPath)) {
      return runMoonbitBuild(requestedEntry);
    }
    if (latestOutput.sourceMapPath && !fs.existsSync(latestOutput.sourceMapPath)) {
      return runMoonbitBuild(requestedEntry);
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

    config(_, { command }) {
      isBuild = command === 'build';
    },

    configResolved(config) {
      ensureProject(config.root);
    },

    buildStart() {
      try {
        if (project) {
          runMoonbitBuild();
        }
      } catch (err: any) {
        console.log('buildStart error', err);
      }
    },

    configureServer(server) {
      const currentProject = ensureProject(server.config.root);
      const watchTargets = [
        path.join(currentProject.moduleRoot, '**/*.mbt'),
        path.join(currentProject.moduleRoot, '**/*.mbti'),
        path.join(currentProject.moduleRoot, '**/moon.pkg'),
        path.join(currentProject.moduleRoot, '**/moon.pkg.json'),
        path.join(currentProject.moduleRoot, 'moon.mod'),
        path.join(currentProject.moduleRoot, 'moon.mod.json'),
      ];
      if (currentProject.workspaceRoot) {
        watchTargets.push(path.join(currentProject.workspaceRoot, 'moon.work'));
      }
      server.watcher.add(watchTargets);
      const onFsChange = (filePath: string) => {
        scheduleRebuild(server, filePath);
      };
      server.watcher.on('add', onFsChange);
      server.watcher.on('change', onFsChange);
      server.watcher.on('unlink', onFsChange);
    },

    resolveId(source) {
      const cleanSource = source.split('?', 1)[0];
      let entryFileName = latestOutput ? path.basename(latestOutput.jsPath) : undefined;
      if (cleanSource.endsWith('.js')) {
        const requestedEntry = path.basename(cleanSource);
        try {
          const needsRefresh = !entryFileName
            || (entryFileName && cleanSource !== `/${entryFileName}` && cleanSource !== entryFileName);
          if (needsRefresh) {
            latestOutput = undefined;
          }
          entryFileName = path.basename(ensureOutput(requestedEntry).jsPath);
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
      if (!shouldRebuildForFile(file)) {
        return modules;
      }
      scheduleRebuild(server, file);
      return [];
    },
  };
}

export default rabbita;
