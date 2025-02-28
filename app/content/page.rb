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
              guide: method(:guide_path)
            }
          }
        )
      end

      # Replaces links to "//_guide/internal-page" with links within the current guide and
      # version, such as "/guides/hanami/v2.2/some-guide/internal-page".
      def guide_path(path)
        url_base + path
      end
    end
  end
end
