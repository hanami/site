# frozen_string_literal: true

module Site
  module Content
    CONTENT_PATH = App.root.join("content").freeze

    DOCS_PATH = CONTENT_PATH.join("docs").freeze
    GUIDES_PATH = CONTENT_PATH.join("guides").freeze

    class NotFoundError < StandardError
      attr_reader :path

      def initialize(path)
        @path = path
        super("no page found at #{path} ")
      end
    end
  end
end
