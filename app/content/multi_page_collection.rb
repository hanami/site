# frozen_string_literal: true

require "front_matter_parser"

module Site
  module Content
    class MultiPageCollection
      attr_reader :root

      attr_reader :url_path

      attr_reader :pages

      def initialize(path:, url_path:)
        @root = CONTENT_PATH.join(path)
        @url_path = url_path
        @pages = []
      end

      def all
        @all ||= ordered_page_paths.map { page_at(it) }
      end

      # TODO: cache from `#all` if already found?
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
          url_path: (path == INDEX_NAME) ? url_path : File.join(url_path, path),
          front_matter: parsed_file.front_matter,
          content: parsed_file.content
        )
      end

      private

      def ordered_page_paths
        @ordered_page_paths ||= [INDEX_NAME] + index_page.front_matter.fetch(:sections, [])
      end

      def index_page
        @index_page ||= page_at(INDEX_NAME)
      end
    end
  end
end
