import { describe, expect, it, beforeEach, afterEach } from "vitest";
import { findClosestIndex, findElements } from "./toc-scroll";

describe(findClosestIndex, () => {
  const values = [0, 1, 3, 10, 11.5];
  it("returns the correct value", () => {
    expect(findClosestIndex(values, 0.6)).toBe(1);
    expect(findClosestIndex(values, 9)).toBe(3);
    expect(findClosestIndex(values, 11)).toBe(4);
    expect(findClosestIndex(values, 100)).toBe(4);
  });
});

describe(findElements, () => {
  let tocContainer: HTMLElement;
  let anchorContainer: HTMLElement;

  beforeEach(() => {
    // Set up DOM structure
    tocContainer = document.createElement("nav");
    tocContainer.innerHTML = `
      <a href="#section1">Section 1</a>
      <a href="#section2">Section 2</a>
      <a href="#section2-1">Section 2.1</a>
      <a href="#byname">By Name</a>
      <a href="#missing">Missing</a>
    `;

    anchorContainer = document.createElement("div");
    anchorContainer.innerHTML = `
      <h2 id="section1">Section 1</h2>
      <h2 id="section2">Section 2</h2>
      <h3 id="section2-1">Section 2.1</h2>
      <a name="byname">By Name</a>
    `;
    anchorContainer.id = "main-content";
    document.body.appendChild(anchorContainer);
    document.body.appendChild(tocContainer);
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  it("finds anchors by id and name and maps them to TOC links", () => {
    const { anchors, anchorToTocLinkMap, tocLinks } = findElements({
      anchorContainerSelector: "#main-content",
      tocContainerNode: tocContainer,
      tocNodeSelector: "a[href^='#']",
    });

    expect(anchors.length).toBe(4);

    // Each anchor should map to the correct TOC link
    anchors.forEach((anchor) => {
      const link = anchorToTocLinkMap.get(anchor);
      expect(link).toBeInstanceOf(HTMLAnchorElement);
      if (anchor.id) {
        expect(link?.getAttribute("href")).toBe(`#${anchor.id}`);
      } else if (anchor.getAttribute("name")) {
        expect(link?.getAttribute("href")).toBe(`#${anchor.getAttribute("name")}`);
      }
    });

    // tocLinks should include all 5 links
    expect(tocLinks.length).toBe(5);
  });

  it("uses document as anchor container if selector is not provided", () => {
    // Move anchors to document body
    document.body.appendChild(anchorContainer);

    const { anchors } = findElements({
      anchorContainerSelector: undefined,
      tocContainerNode: tocContainer,
      tocNodeSelector: "a[href^='#']",
    });

    expect(anchors.length).toBe(4);
  });

  it("throws if anchor container selector is invalid and function is modified to throw", () => {
    expect(() =>
      findElements({
        anchorContainerSelector: "#does-not-exist",
        tocContainerNode: tocContainer,
        tocNodeSelector: "a[href^='#']",
      }),
    ).toThrow();
  });
});
