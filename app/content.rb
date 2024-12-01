# frozen_string_literal: true

module Site
  module Content
    CONTENT_PATH = App.root.join("content").freeze

    DOCS_PATH = CONTENT_PATH.join("docs").freeze
    GUIDES_PATH = CONTENT_PATH.join("guides").freeze
  end
end
