# frozen_string_literal: true

module Site
  module Repos
    class DocRepo < Site::DB::Repo
      def latest_by_org
        docs
          .visible
          .order(docs[:version].desc)
          .group(:slug)
          .to_a
          .group_by(&:org)
      end
    end
  end
end
