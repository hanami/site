export function tocScrollViewFn(
  tocContainerNode: HTMLElement,
  {
    anchorContainerSelector,
    tocNodeSelector = "a[href^='#']",
  }: {
    anchorContainerSelector?: string;
    tocNodeSelector?: string;
  },
) {
  const tocLinks = Array.from(
    tocContainerNode.querySelectorAll<HTMLAnchorElement>(tocNodeSelector),
  );

  let anchorContainer: ParentNode = document;
  if (anchorContainerSelector) {
    const foundAnchorContainer = document.querySelector(anchorContainerSelector);
    if (foundAnchorContainer) {
      anchorContainer = foundAnchorContainer;
    }
  }

  // Map: anchor element -> toc link
  const anchorToTocLink = new Map<Element, HTMLAnchorElement>();

  tocLinks.forEach((link) => {
    const href = link.getAttribute("href");
    if (!href || !href.startsWith("#")) return;
    const id = href.slice(1);
    // Try to find by ID or by name
    const anchor =
      anchorContainer.querySelector(`#${CSS.escape(id)}`) ||
      anchorContainer.querySelector(`[name="${CSS.escape(id)}"]`);
    if (anchor) {
      anchorToTocLink.set(anchor, link);
    }
  });

  const anchors = Array.from(anchorToTocLink.keys());

  // 3. Set up IntersectionObserver
  async function onScroll() {
    const viewportMarginThreshold = window.innerHeight * 0.1;
    const yPositions: number[] = [];
    const resolvers: ((value: void | PromiseLike<void>) => void)[] = [];
    const promises = anchors.map(
      () =>
        new Promise<void>((resolve) => {
          resolvers.push(resolve);
        }),
    );

    // This abuses IntersectionObserver to get the positions of each anchor element without causing
    // reflows (when using `getBoundingClientRect` directly)
    const observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        const { target, boundingClientRect } = entry;
        const index = anchors.indexOf(target);

        const { y } = boundingClientRect;
        yPositions[index] = y;

        const resolver = resolvers[index];
        if (resolver) {
          resolver();
        } else {
          throw new Error("Mismatch");
        }
      }

      // Disconnect the observer immediately
      observer.disconnect();
    });

    // Trigger observer for each anchor
    anchors.forEach((anchor) => observer.observe(anchor));

    await Promise.all(promises);

    yPositions.unshift(window.scrollY * -1);
    const closestIndex = findClosestIndex(yPositions, viewportMarginThreshold) - 1;
    let activeAnchor = anchors[closestIndex];

    if (activeAnchor) {
      const activeLink = anchorToTocLink.get(activeAnchor);
      if (activeLink) {
        activateLink(activeLink);
      }
    } else {
      activateLink(undefined);
    }
  }

  window.addEventListener("scroll", onScroll);

  function activateLink(activeLinkNode: HTMLElement | undefined) {
    tocLinks.forEach((node) => node.classList.remove("text-rose-500"));
    if (activeLinkNode) {
      activeLinkNode.classList.add("text-rose-500");
    }
  }

  return {
    destroy: () => {
      window.removeEventListener("scroll", onScroll);
    },
  };
}

const findClosestIndex = (arr: number[], target: number) =>
  arr.reduce(
    (closest, curr, i) => (Math.abs(curr - target) < Math.abs(arr[closest] - target) ? i : closest),
    0,
  );
