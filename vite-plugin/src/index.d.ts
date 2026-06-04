import type { Plugin } from 'vite';

type RabbitaOptions = {
    mainPkgDir?: string;
    /**
     * @deprecated Use mainPkgDir instead.
     */
    main?: string;
    /**
     * @deprecated Use mainPkgDir instead.
     */
    moonModDir?: string;
};

/**
 * Rabbita Vite plugin.
 *
 * @param options.mainPkgDir Optional filesystem path to the main package
 * directory, relative to the Vite config file. The plugin builds it with
 * `moon build .`.
 * @param options.main Deprecated compatibility selector for generated JS
 * output. Use mainPkgDir instead.
 * @param options.moonModDir Deprecated compatibility build cwd. Use
 * mainPkgDir instead.
 */
export declare function rabbita(options?: RabbitaOptions): Plugin;
export default rabbita;
