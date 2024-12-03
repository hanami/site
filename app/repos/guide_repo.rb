# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      ContentNotFoundError = Class.new(ROM::TupleCountMismatchError)

      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def page(guide:, path:)
        file = files.find(guide.relative_content_path.join("#{path}.md"))
        raise ContentNotFoundError if file.failure?

        file = file.value!
        Structs::GuidePage.new(guide:, content_md: file.content)
      end

      private

      # Workaround until https://github.com/hanami/hanami/issues/1483 is fixed and we can switch
      # back to using `Deps` for this.
      def files
        @files ||= Content::Files.new
      end
    end
  end
end
