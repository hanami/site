import { describe, expect, it } from "vitest";
import { findClosestIndex } from "./toc-scroll";

describe(findClosestIndex, () => {
  const values = [0, 1, 3, 10, 11.5];
  it("returns the correct value", () => {
    expect(findClosestIndex(values, 0.6)).toBe(1);
    expect(findClosestIndex(values, 9)).toBe(3);
    expect(findClosestIndex(values, 11)).toBe(4);
    expect(findClosestIndex(values, 100)).toBe(4);
  });
});
