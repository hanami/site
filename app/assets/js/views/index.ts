import type { Views } from "@icelab/defo";

import { docsearchViewFn } from "./docsearch/docsearch";
import { sizeToVarViewFn } from "./size-to-var";
import { tocScrollViewFn } from "./toc-scroll";
import { breakpointFilter } from "~/utils/breakpoints";

export const views: Views = {
  docsearch: docsearchViewFn,
  sizeToVar: sizeToVarViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
};
