# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def all_with(org:, version:)
        guides.where(org:, version:).to_a
      end

      def latest_by_org
        Content::DEFAULT_GUIDE_VERSIONS.to_h { |org, version|
          [
            org,
            guides.where(org:, version:).order(guides[:position].asc)
          ]
        }
      end
    end
  end
end
