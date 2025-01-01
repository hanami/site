# auto_register: false
# frozen_string_literal: true

require "commonmarker"

module Site
  module Content
    class Page < Site::Struct
      attribute :front_matter, Types::Strict::Hash.constructor(->(hsh) { hsh.transform_keys(&:to_sym) })
      attribute :content, Types::Strict::String

      def title
        front_matter.fetch(:title)
      end

      def content_md = content

      def content_html
        @content_html ||= Commonmarker.to_html(content_md).html_safe
      end
    end
  end
end
