import type { Views } from "@icelab/defo/dist/types";
import { docsearchViewFn } from "./docsearch/docsearch";
import { sizeToVarViewFn } from "./size-to-var";
import { tocScrollViewFn } from "./toc-scroll";

export const views: Views = {
  docsearch: docsearchViewFn,
  sizeToVar: sizeToVarViewFn,
  tocScroll: tocScrollViewFn,
};
