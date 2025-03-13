# frozen_string_literal: true

module Site
  module Repos
    class DocRepo < Site::DB::Repo
      def find(slug:, version:)
        docs.where(slug:, version:).one!
      end

      def all
        docs.to_a
      end

      def latest_version(slug:)
        gems.where(slug: slug).pluck(:latest_version).first
      end

      def versions_for(slug:)
        docs.where(slug:).group(:version).order(docs[:version].desc).pluck(:version).to_a
      end

      def latest_by_org
        gems
          .select(:org, :slug)
          .select_append { latest_version.as(:version) }
          .as(:doc)
          .to_a
          .group_by(&:org)
      end
    end
  end
end
