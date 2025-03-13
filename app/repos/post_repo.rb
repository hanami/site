# frozen_string_literal: true

module Site
  module Repos
    class PostRepo < Site::DB::Repo
      def get(permalink)
        posts.where(permalink:).one!
      end

      def all
        posts.to_a
      end

      def latest(page: 1, per_page: 10)
        posts.per_page(per_page).page(page).to_a
      end

      def total_pages(per_page: 10)
        posts.per_page(per_page).pager.total_pages
      end

      def posts
        super.published.order { published_at.desc }
      end
    end
  end
end
