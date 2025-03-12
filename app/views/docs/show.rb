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
          doc.pages[path]
        end

        expose :version, decorate: false

        expose :latest_version, decorate: false do |slug:|
          doc_repo.latest_version(slug:)
        end

        expose :other_versions, decorate: false do |slug:|
          doc_repo.versions_for(slug:)
        end

        scope do
          # Strip leading "v" for docsearch:version meta, which wants a pure numerical version
          def version_number
            version.sub(/^v/, "")
          end
        end
      end
    end
  end
end
