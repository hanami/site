import type { Views } from "@icelab/defo/dist/types";
import { docsearchViewFn } from "./docsearch/docsearch";

export const views: Views = {
  docsearch: docsearchViewFn,
};
