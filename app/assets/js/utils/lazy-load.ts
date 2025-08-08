import type { ViewFn, ViewProps } from "@icelab/defo";

/**
 * Lazy load wrapper for view functions
 *
 * Allows us to use a dynamic import to split the loading of view function out into separate bundles
 * (as long as the bundler supports it).
 *
 * @example
 * viewName: lazyLoadView(async () => {
 *   const { viewNameFn } = await import("./view-name-fn");
 *   return viewNameFn;
 * })
 */
export const lazyLoadView = <T extends () => Promise<ViewFn<any>>>(importFn: T) => {
  type Props = T extends () => Promise<ViewFn<infer P>> ? P : ViewProps;
  return (node: HTMLElement, props: Props) => importFn().then((viewFn) => viewFn(node, props));
};
