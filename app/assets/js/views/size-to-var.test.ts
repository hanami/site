import { beforeAll, expect, test } from "vitest";
import defo from "@icelab/defo";
import { sizeToVarViewFn } from "./size-to-var";

// Create very basic ResizeObserver implementation that we can send callbacks too
const callbacks = new Set<[ResizeObserverCallback, ResizeObserver]>();
class MockResizeObserver {
  constructor(callback: ResizeObserverCallback) {
    callbacks.add([callback, this]);
  }
  observe = () => {};
  unobserve = () => {};
  disconnect = () => {
    callbacks.clear();
  };
}

// Render a config to the DOM and initialise defo with our test view function
function render(config: Parameters<typeof sizeToVarViewFn>[1]) {
  document.body.innerHTML = `<div data-defo-size-to-var='${JSON.stringify(config)}'></div>`;
  defo({ views: { sizeToVar: sizeToVarViewFn } });
}

// Create a mock ResizeObserverEntry value
function mockEntry({
  border,
  height,
  width,
}: {
  border: number;
  height: number;
  width: number;
}): ResizeObserverEntry[] {
  return [
    {
      borderBoxSize: [
        {
          blockSize: height + border,
          inlineSize: width + border,
        },
      ],
      contentBoxSize: [{ blockSize: height, inlineSize: width }],
      contentRect: {
        x: 0,
        y: 0,
        width,
        height,
        top: 0,
        right: width,
        bottom: height,
        left: 0,
        toJSON: () => {},
      },
      devicePixelContentBoxSize: [{ blockSize: height * 2, inlineSize: width * 2 }],
      target: document.documentElement, // Dumb value since we don’t use this currently
    },
  ];
}

const blockVarName = "--block";
const inlineVarName = "--inline";

beforeAll(async () => {
  const originalResizeObserver = globalThis.ResizeObserver;
  globalThis.ResizeObserver = MockResizeObserver as any;

  return () => {
    globalThis.ResizeObserver = originalResizeObserver;
  };
});

test("sets the expected value for variables with 'border' box-sizing", async () => {
  render({ blockVarName, inlineVarName, boxSize: "border" });

  callbacks.forEach(([cb, observer]) =>
    cb(
      mockEntry({
        border: 10,
        height: 100,
        width: 50,
      }),
      observer,
    ),
  );

  expect(document.documentElement.style.getPropertyValue("--block")).toBe("110px");
  expect(document.documentElement.style.getPropertyValue("--inline")).toBe("60px");
});

test("defaults to 'border' box-sizing", async () => {
  render({ blockVarName, inlineVarName });

  callbacks.forEach(([cb, observer]) =>
    cb(
      mockEntry({
        border: 10,
        height: 100,
        width: 50,
      }),
      observer,
    ),
  );

  expect(document.documentElement.style.getPropertyValue("--block")).toBe("110px");
  expect(document.documentElement.style.getPropertyValue("--inline")).toBe("60px");
});

test("sets the expected value for variables with 'content' box-sizing", async () => {
  render({ blockVarName, inlineVarName, boxSize: "content" });

  callbacks.forEach(([cb, observer]) =>
    cb(
      mockEntry({
        border: 10,
        height: 100,
        width: 50,
      }),
      observer,
    ),
  );

  expect(document.documentElement.style.getPropertyValue("--block")).toBe("100px");
  expect(document.documentElement.style.getPropertyValue("--inline")).toBe("50px");
});
