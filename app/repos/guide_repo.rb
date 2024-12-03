# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      ContentNotFoundError = Class.new(ROM::TupleCountMismatchError)

      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def page(guide:, path:)
        file_path = guide.path.join("#{path}.md")
        raise ContentNotFoundError unless file_path.exist?

        Structs::GuidePage.new(guide:, content_md: File.read(file_path))
      end
    end
  end
end
