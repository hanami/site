# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        expose :guide do |org:, version:, slug:|
          guide_repo.find(org:, version:, slug:)
        end

        expose :page do |guide, path:|
          guide.pages[path]
        end

        expose :org, decorate: false

        expose :version, decorate: false

        expose :latest_version, decorate: false do |org:|
          guide_repo.latest_version(org:)
        end

        expose :other_guides do |org:, version:|
          guide_repo.all_for(org:, version:)
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
