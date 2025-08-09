import { expect, test } from "vitest";
import { lazyLoadView } from "./lazy-load";

type TestProps = { message: string };
type ViewFn<P> = (node: HTMLElement, props: P) => void;

const mockViewFn: ViewFn<TestProps> = (node, props) => {
  node.textContent = props.message;
};

const importFn = async () => mockViewFn;

test("should lazy load and invoke the view function with node and props", async () => {
  const node = document.createElement("div");
  const props = { message: "Hello, lazy!" };

  const lazyFn = lazyLoadView(importFn);

  await lazyFn(node, props);

  expect(node.textContent).toBe("Hello, lazy!");
});

test("should work with different props", async () => {
  const node = document.createElement("div");
  const props = { message: "Another test" };

  const lazyFn = lazyLoadView(importFn);
  await lazyFn(node, props);

  expect(node.textContent).toBe("Another test");
});
