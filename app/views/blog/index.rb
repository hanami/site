# frozen_string_literal: true

module Site
  module Views
    module Blog
      class Index < Site::View
        include Deps["repos.post_repo"]

        expose :posts do |page:|
          post_repo.latest(page:)
        end

        expose :page, decorate: false
      end
    end
  end
end
