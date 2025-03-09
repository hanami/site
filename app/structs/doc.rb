# frozen_string_literal: true

module Site
  module Structs
    class Doc < Site::DB::Struct
      def title = slug

      def pages
        @pages ||= Content::PageCollection.new(
          root: content_path,
          base_url_path: url_path
        )
      end

      def url_path
        "/docs/#{slug}/#{version}"
      end

      def content_path
        Content::DOCS_PATH.join(org, slug, version)
      end

      def relative_content_path
        content_path.relative_path_from(Content::CONTENT_PATH)
      end
    end
  end
end
