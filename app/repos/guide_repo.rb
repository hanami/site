# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def all(org:, version:)
        guides.where(org:, version:).to_a
      end
    end
  end
end
