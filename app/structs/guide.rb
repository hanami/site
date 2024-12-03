# frozen_string_literal: true

module Site
  module Structs
    class Guide < Site::DB::Struct
      def path
        Content::GUIDES_PATH.join(org, version, slug)
      end

      def relative_content_path
        path.relative_path_from(Content::CONTENT_PATH)
      end
    end
  end
end
