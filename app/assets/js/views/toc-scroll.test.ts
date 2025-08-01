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
      <div class="indicator" />
    `;

    anchorContainer = document.createElement("div");
    anchorContainer.innerHTML = `
      <h2 id="section1">Section 1</h2>
      <h2 id="section2">Section 2</h2>
      <h3 id="section2-1">Section 2.1</h3>
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
    const { anchors, anchorToLinkMap, links } = findElements({
      anchorContainerSelector: "#main-content",
      indicatorSelector: ".indicator",
      linkContainerNode: tocContainer,
      linkSelector: "a[href^='#']",
    });

    expect(anchors.length).toBe(4);

    // Each anchor should map to the correct link
    anchors.forEach((anchor) => {
      const linkTuple = anchorToLinkMap.get(anchor);
      expect(linkTuple).toBeDefined();
      const [link] = linkTuple!;
      expect(link).toBeInstanceOf(HTMLAnchorElement);
      if (anchor.id) {
        expect(link.getAttribute("href")).toBe(`#${anchor.id}`);
      } else if (anchor.getAttribute("name")) {
        expect(link.getAttribute("href")).toBe(`#${anchor.getAttribute("name")}`);
      }
    });

    expect(links.length).toBe(4);
  });

  it("throws if a TOC link is missing its anchor", () => {
    tocContainer.innerHTML += `<a href="#missing">Missing</a>`;
    expect(() =>
      findElements({
        anchorContainerSelector: "#main-content",
        indicatorSelector: ".indicator",
        linkContainerNode: tocContainer,
        linkSelector: "a[href^='#']",
      }),
    ).toThrow(/Anchor missing for link with href: #missing/);
  });

  it("uses document as anchor container if selector is not provided", () => {
    const { anchors } = findElements({
      anchorContainerSelector: undefined,
      indicatorSelector: ".indicator",
      linkContainerNode: tocContainer,
      linkSelector: "a[href^='#']",
    });

    expect(anchors.length).toBe(4);
  });

  it("throws if anchor container selector is invalid", () => {
    expect(() =>
      findElements({
        anchorContainerSelector: "#does-not-exist",
        indicatorSelector: ".indicator",
        linkContainerNode: tocContainer,
        linkSelector: "a[href^='#']",
      }),
    ).toThrow(/Anchor container not found in document/);
  });

  it("returns undefined for indicator if selector does not match", () => {
    const { indicator } = findElements({
      anchorContainerSelector: "#main-content",
      linkContainerNode: tocContainer,
      linkSelector: "a[href^='#']",
      indicatorSelector: ".does-not-exist",
    });
    expect(indicator).toBeUndefined();
  });

  it("returns the indicator element if selector matches", () => {
    const indicator = document.createElement("div");
    indicator.className = "toc-indicator";
    document.body.appendChild(indicator);

    const result = findElements({
      anchorContainerSelector: "#main-content",
      linkContainerNode: tocContainer,
      linkSelector: "a[href^='#']",
      indicatorSelector: ".toc-indicator",
    });
    expect(result.indicator).toBe(indicator);

    indicator.remove();
  });
});
