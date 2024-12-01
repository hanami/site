# frozen_string_literal: true

require "commonmarker"

module Site
  module Structs
    class GuidePage < Site::DB::Struct
      def content_html
        @content_html ||= begin
          Commonmarker.to_html(content_md).html_safe
        end
      end
    end
  end
end
