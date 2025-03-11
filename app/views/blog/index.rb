# frozen_string_literal: true

module Site
  module Views
    module Blog
      class Index < Site::View
        include Deps["repos.post_repo"]

        expose :posts do
          post_repo.latest
        end
      end
    end
  end
end
