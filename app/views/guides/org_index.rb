# frozen_string_literal: true

module Site
  module Views
    module Guides
      class OrgIndex < Site::View
        include Deps["repos.guide_repo"]

        expose :guides do |org:, version:|
          guide_repo.all_for(org:, version:)
        end

        expose :versions, decorate: false do |org:|
          guide_repo.versions_for(org:)
        end

        expose :org_slug, decorate: false do |org:|
          org
        end

        expose :version, decorate: false
      end
    end
  end
end
