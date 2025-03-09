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

        expose :other_guides do |org:, version:|
          guide_repo.all_for(org:, version:)
        end
      end
    end
  end
end
