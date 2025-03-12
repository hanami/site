import "../css/app.css";
import "@docsearch/css";

import docsearch from "@docsearch/js";

docsearch({
  container: "#docsearch",
  appId: window.app_settings.docsearch_app_id,
  apiKey: window.app_settings.docsearch_api_key,
  indexName: window.app_settings.docsearch_index_name,
  searchParameters: {
    facetFilters: ["version:latest"],
  },
});
