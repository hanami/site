import type { Views } from "@icelab/defo/dist/types";
import { docsearchViewFn } from "./docsearch/docsearch";
import { sizeToVarViewFn } from "./size-to-var";

export const views: Views = {
  docsearch: docsearchViewFn,
  sizeToVar: sizeToVarViewFn,
};
