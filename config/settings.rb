# frozen_string_literal: true

module Site
  class Settings < Hanami::Settings
    # Site URL (without trailing slash)
    setting :site_url,
      constructor: Types::String.optional.constructor(->(v) { v.sub(%r{/$}, "") }),
      default: "https://hanamirb.org"

    # DocSearch settings (see also config/app.js)
    setting :docsearch_app_id, constructor: Types::String
    setting :docsearch_api_key, constructor: Types::String
    setting :docsearch_index_name, constructor: Types::String
  end
end
