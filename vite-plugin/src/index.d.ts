import type { Plugin } from 'vite';

type RabbitaOptions = {
    main?: string;
    moonModDir?: string;
};

/**
 * Rabbita Vite plugin.
 *
 * @param options.main Optional relative package path for selecting the
 * MoonBit main package (for example: "main" or "app/web").
 * @param options.moonModDir Optional path to the directory containing
 * moon.mod or moon.mod.json. Defaults to the Vite root.
 */
export declare function rabbita(options?: RabbitaOptions): Plugin;
export default rabbita;
