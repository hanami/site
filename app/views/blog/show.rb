# frozen_string_literal: true

module Site
  module Views
    module Blog
      class Show < Site::View
        include Deps["repos.post_repo"]

        expose :post do |permalink:|
          post_repo.get(permalink)
        end
      end
    end
  end
end
