export function tocScrollViewFn(
  linkContainerNode: HTMLElement,
  {
    anchorContainerSelector,
    linkSelector = "a[href^='#']",
  }: {
    anchorContainerSelector?: string;
    linkSelector?: string;
  },
) {
  const { anchors, anchorToLinkMap, links } = findElements({
    anchorContainerSelector,
    linkContainerNode,
    linkSelector,
  });

  function onChangeAnchor(activeAnchor: Element | undefined) {
    const activeLinkNode = activeAnchor ? anchorToLinkMap.get(activeAnchor) : undefined;
    links.forEach((node) => node.classList.remove("text-rose-500"));
    if (activeLinkNode) {
      activeLinkNode.classList.add("text-rose-500");
    }
  }

  const onScroll = createOnScrollFn({
    anchors,
    onChangeAnchor,
  });

  window.addEventListener("scroll", onScroll);

  return {
    destroy: () => {
      window.removeEventListener("scroll", onScroll);
    },
  };
}

/**
 * Find all the elements we need:
 */
export function findElements({
  anchorContainerSelector,
  linkContainerNode,
  linkSelector,
}: {
  anchorContainerSelector: string | undefined;
  linkContainerNode: HTMLElement;
  linkSelector: string;
}) {
  const links = Array.from(linkContainerNode.querySelectorAll<HTMLAnchorElement>(linkSelector));

  let anchorContainer: ParentNode = document;
  if (anchorContainerSelector) {
    const foundAnchorContainer = document.querySelector(anchorContainerSelector);
    if (foundAnchorContainer) {
      anchorContainer = foundAnchorContainer;
    } else {
      throw new Error("Anchor container not found in document");
    }
  }

  // Map: anchor element -> toc link
  const anchorToLinkMap = new Map<Element, HTMLAnchorElement>();

  links.forEach((link) => {
    const href = link.getAttribute("href");
    if (!href || !href.startsWith("#")) return;
    const id = href.slice(1);
    // Try to find by ID or by name
    const anchor =
      anchorContainer.querySelector(`#${CSS.escape(id)}`) ||
      anchorContainer.querySelector(`[name="${CSS.escape(id)}"]`);
    if (anchor) {
      anchorToLinkMap.set(anchor, link);
    }
  });

  const anchors = Array.from(anchorToLinkMap.keys());

  return {
    anchors,
    anchorToLinkMap,
    links,
  };
}

/**
 * findClosestIndex
 * Find the value in the passed array closest to the `target`.
 * @example
 * const values = [1,2,10]
 * findClosestIndex(values, 9)
 * // -> 2
 */
export function findClosestIndex(arr: number[], target: number) {
  return arr.reduce((closestIndex, curr, i) => {
    const closestIndexValue = arr[closestIndex] ?? 0;
    if (Math.abs(curr - target) < Math.abs(closestIndexValue - target)) {
      return i;
    } else {
      return closestIndex;
    }
  }, 0);
}

// How much of the window to offset the scroll-comparison value by
const WINDOW_THRESHOLD_PERCENTAGE = 0.1;

/**
 * Create the onScroll function
 */
function createOnScrollFn({
  anchors,
  onChangeAnchor,
}: {
  anchors: Element[];
  onChangeAnchor: (activeAnchor: Element | undefined) => void;
}) {
  return async () => {
    const viewportMarginThreshold = window.innerHeight * WINDOW_THRESHOLD_PERCENTAGE;
    const yPositions: number[] = [];

    // Create an array of Promises and their resolver functions that matches the length of the
    // `anchors` array.
    const resolverFns: ((value: void | PromiseLike<void>) => void)[] = [];
    const promises = anchors.map(
      () =>
        new Promise<void>((resolve) => {
          resolverFns.push(resolve);
        }),
    );

    // This abuses IntersectionObserver to get the positions of each anchor element without causing
    // reflows (which would occur when using `getBoundingClientRect` directly).
    const observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        const { target, boundingClientRect } = entry;
        const index = anchors.indexOf(target);

        const { y } = boundingClientRect;
        yPositions[index] = y;

        // Find the corresponding resolvedFn and call it.
        const resolverFn = resolverFns[index];
        if (resolverFn) {
          resolverFn();
        } else {
          throw new Error("Mismatch between expect entries and resolvers");
        }
      }

      // Disconnect the observer immediately after the entry resolves
      observer.disconnect();
    });

    // Trigger observer for each anchor
    anchors.forEach((anchor) => observer.observe(anchor));

    // Wait for every item to be measured.
    await Promise.all(promises);

    // Add the window scrollY offset to the start of the yPosition array so we use it as an anchor
    // to ensure we don’t always select the first item.
    yPositions.unshift(window.scrollY * -1);

    // Find the closest matching position (accounting for the fake value from the scroll position)
    const closestIndex = findClosestIndex(yPositions, viewportMarginThreshold) - 1;
    onChangeAnchor(anchors[closestIndex]);
  };
}
