import { ForesightManager } from "js.foresight";

ForesightManager.initialize();

type Props = {
  elementSelector?: string;
};

const preloadedPaths = new Set();

const createPreloadCallback = (href: string | null) => async () => {
  if (!href || preloadedPaths.has(href)) {
    return;
  }
  preloadedPaths.add(href);
  await fetch(href);
};

export const foresightViewFn = (node: HTMLElement, { elementSelector = "a[href^='/']" }: Props) => {
  const elements = [...node.querySelectorAll(elementSelector)];
  elements.map((element) =>
    ForesightManager.instance.register({
      element,
      callback: createPreloadCallback(element.getAttribute("href")),
    }),
  );
};
