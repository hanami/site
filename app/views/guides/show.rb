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
          guide.pages.page_at(path)
        end

        expose :all_guides do |org:, version:|
          guide_repo.all(org:, version:)
        end
      end
    end
  end
end
