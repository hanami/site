# frozen_string_literal: true

require "commonmarker"
require "dry/struct"

module Site
  module Structs
    class GuidePage < Dry::Struct
      attribute :guide, Guide
      attribute :content_md, Types::Strict::String

      def content_html
        @content_html ||= begin
          Commonmarker.to_html(content_md).html_safe
        end
      end
    end
  end
end
