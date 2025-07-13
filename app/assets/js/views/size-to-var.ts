/**
 * sizeToVar
 *
 * Observes the given `node` using ResizeObserver and translates its size into named CSS variables
 * on the :root element (`documentElement`)
 *
 * @example
 * <div data-def-size-to-var='{"blockVarName": "--block"}' style="width: 50px" />
 * --> <html style="--block: 50px">
 */
export const sizeToVarViewFn = (
  node: HTMLElement,
  {
    blockVarName,
    inlineVarName,
    boxSize = "border",
  }: { blockVarName?: string; inlineVarName?: string; boxSize?: "border" | "content" },
) => {
  if (!blockVarName && !inlineVarName) return;

  const root = document.documentElement;
  const setVarIfChanged = (name: string, value: string) => {
    if (root.style.getPropertyValue(name) !== value) {
      root.style.setProperty(name, value);
    }
  };

  const resizeObserver = new ResizeObserver((entries) => {
    for (const entry of entries) {
      const boxSizes = entry[`${boxSize}BoxSize`];
      const size = Array.isArray(boxSizes) ? boxSizes[0] : boxSizes;
      if (!size) continue;

      if (blockVarName) {
        setVarIfChanged(blockVarName, `${size.blockSize}px`);
      }
      if (inlineVarName) {
        setVarIfChanged(inlineVarName, `${size.inlineSize}px`);
      }
    }
  });

  resizeObserver.observe(node);

  return {
    destroy: () => {
      resizeObserver.disconnect();
    },
  };
};
