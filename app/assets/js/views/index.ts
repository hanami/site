import type { Views } from "@icelab/defo/dist/types";
import { docsearchViewFn } from "./docsearch";

export const views: Views = {
  docsearch: docsearchViewFn,
};
