# frozen_string_literal: true

module Site
  module Content
    DEFAULT_GUIDE_VERSIONS = {
      "dry-rb" => "v1.0",
      "hanami" => "v2.2",
      "rom" => "v5.0"
    }.freeze

    CONTENT_PATH = App.root.join("content").freeze
    POSTS_PATH = CONTENT_PATH.join("posts").freeze
    DOCS_PATH = CONTENT_PATH.join("docs").freeze
    GUIDES_PATH = CONTENT_PATH.join("guides").freeze

    INDEX_PAGE_PATH = "_index"
    PAGES_FRONTMATTER_KEY = :pages

    class NotFoundError < StandardError
      attr_reader :path

      def initialize(path)
        @path = path
        super("no page found at #{path} ")
      end
    end
  end
end
