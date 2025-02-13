# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Index < Site::View
        include Deps["repos.guide_repo"]

        expose :guides do
          guide_repo.latest_by_org
        end

        expose :versions do
          guide_repo.versions_by_org
        end
      end
    end
  end
end
