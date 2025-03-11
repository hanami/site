# frozen_string_literal: true

module Site
  module Repos
    class PostRepo < Site::DB::Repo
      def get(permalink)
        where(permalink:).one!
      end

      def latest(page: 1)
        posts.page(page).to_a
      end

      def posts
        super.published.order { published_at.desc }
      end
    end
  end
end
