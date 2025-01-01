# frozen_string_literal: true

require "front_matter_parser"

module Site
  module Content
    class MultiPageCollection
      attr_reader :root

      attr_reader :pages

      def initialize(path)
        @root = CONTENT_PATH.join(path)
        @pages = []
      end

      def page_at(path)
        page_path = root.join(path)

        begin
          parsed_file = FrontMatterParser::Parser.parse_file("#{page_path}.md")
        rescue Errno::ENOENT
          raise Content::NotFoundError, page_path
        end

        # TODO: figure out if there's value in passing `self` to the page, to
        # allow the page to expose its siblings, etc.
        Content::Page.new(
          front_matter: parsed_file.front_matter,
          content: parsed_file.content
        )
      end
    end
  end
end
