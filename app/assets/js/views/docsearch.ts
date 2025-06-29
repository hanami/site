import "@docsearch/css";
import docsearch from "@docsearch/js";

type Props = { appId: string; apiKey: string; indexName: string };

export const docsearchViewFn = (container: HTMLElement, { appId, apiKey, indexName }: Props) => {
  docsearch({
    container,
    appId,
    apiKey,
    indexName,
    searchParameters: {
      facetFilters: ["version:latest"],
    },
  });

  return {
    destroy: () => {},
  };
};
