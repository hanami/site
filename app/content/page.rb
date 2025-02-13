# auto_register: false
# frozen_string_literal: true

require "commonmarker"

module Site
  module Content
    class Page < Site::Struct
      attribute :url_path, Types::Strict::String
      attribute :front_matter, Types::Strict::Hash.constructor(->(hsh) { hsh.transform_keys(&:to_sym) })
      attribute :content, Types::Strict::String

      class Heading < Site::Struct
        attribute :text, Types::Strict::String
        attribute :header_level, Types::Strict::Integer
      end

      def title
        front_matter.fetch(:title)
      end

      def content_md
        content
      end

      def content_html
        @content_html ||= content_doc.to_html.html_safe
      end

      def headings
        @headings ||= begin
          headings = []

          content_doc.walk do |node|
            next unless node.type == :heading

            headings << Heading.new(
              # Presume headers contain a single child `:text` node for their text
              text: node.each.first.string_content,
              header_level: node.header_level
            )
          end

          headings
        end
      end

      private

      def content_doc
        @content_doc ||= Commonmarker.parse(content_md)
      end
    end
  end
end
