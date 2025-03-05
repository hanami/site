# frozen_string_literal: true

module Site
  module Views
    module Docs
      class Show < Site::View
        include Deps["repos.doc_repo"]

        expose :doc do |slug:, version:|
          doc_repo.find(slug:, version:)
        end

        expose :page do |doc, path:|
          doc.pages.page_at(path)
        end
      end
    end
  end
end
