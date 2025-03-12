# frozen_string_literal: true

module Site
  module Views
    module Blog
      class Index < Site::View
        include Deps["repos.post_repo"]

        expose :posts do |page:|
          post_repo.latest(page:, per_page:)
        end

        expose :per_page, decorate: false
        expose :page, decorate: false

        private

        def per_page = 10
      end
    end
  end
end
