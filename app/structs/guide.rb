# frozen_string_literal: true

module Site
  module Structs
    class Guide < Site::DB::Struct
      def pages
        @pages ||= Content::MultiPageCollection.new(relative_content_path)
      end

      def url_path
        "/#{relative_content_path}"
      end

      def content_path
        Content::GUIDES_PATH.join(org, version, slug)
      end

      def relative_content_path
        content_path.relative_path_from(Content::CONTENT_PATH)
      end
    end
  end
end
