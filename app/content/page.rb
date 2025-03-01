# auto_register: false
# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

module Site
  module Content
    class Page < Site::Struct
      attribute :url_base, Types::Strict::String
      attribute :url_path, Types::Strict::String
      attribute :front_matter, Types::Strict::Hash.constructor(->(hsh) { hsh.transform_keys(&:to_sym) })
      attribute :content, Types::Strict::String

      class Heading < Site::Struct
        attribute :text, Types::Strict::String
        attribute :href, Types::Strict::String
        attribute :level, Types::Strict::Integer
      end

      def title
        front_matter.fetch(:title)
      end

      def headings
        @headings ||= content_data.fetch(:headings).map { Heading.new(**it) }
      end

      def content_md
        content
      end

      def content_html
        @content_html ||= content_data.fetch(:output).html_safe
      end

      private

      ContentPipeline = HTMLPipeline.new(
        convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
        node_filters: [
          Content::Filters::LinkableHeadingsFilter.new,
          Content::Filters::InternalLinksFilter.new
        ]
      )
      private_constant :ContentPipeline

      def content_data
        @content_data ||= ContentPipeline.call(
          content_md,
          context: {
            internal_links: {
              page: method(:page_path),
              file: method(:page_path),
              guide: method(:guide_path),
              org_guide: method(:org_guide_path)
            }
          }
        )
      end

      # Transforms "//page/page-slug" into a path within the current guide and version, such as
      # "/guides/hanami/v2.2/current-guide/page-slug".
      def page_path(path)
        url_base + path
      end

      # Transforms "//guide/guide-slug/page-slug" into a path within the current version, such as
      # "/guides/hanami/v2.2/guide-slug/page-slug".
      #
      # To link to the guide's index page, provide a guide slug only.
      def guide_path(path)
        url_base_without_slug = url_base.split("/")[0..-2].join("/")
        url_base_without_slug + path
      end

      # Transforms "//org_guide/org-slug/guide-slug" into a versionless path for the guide within
      # the given org.
      #
      # Visitors to that link will then be redirected to the latest version of the guide.
      def org_guide_path(path)
        "/guides/#{path}"
      end
    end
  end
end
