# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def page(org:, version:, slug:, path:)
        page = guides
          .where(org:, version:, slug:)
          .select_append { `''`.as(:content_md) }
          .as(:guide_page)
          .one!

        # TODO: make safe
        content_md = File.read(Content::GUIDES_PATH.join(org, version, slug, "#{path}.md"))

        page.new(content_md:)
      end

    end
  end
end
