# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        expose :guide_page do |org:, version:, slug:, path:|
          guide_repo.page(org:, version:, slug:, path:)
        end
      end
    end
  end
end
