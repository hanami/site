# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Index < Site::View
        include Deps["repos.guide_repo"]

        expose :hanami_guides do |guides|
          guides.fetch("hanami")
        end

        expose :dry_rb_guides do |guides|
          guides.fetch("dry-rb")
        end

        expose :rom_guides do |guides|
          guides.fetch("rom")
        end

        private_expose :guides do
          guide_repo.latest_by_org
        end
      end
    end
  end
end
