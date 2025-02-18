# auto_register: false
# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

module Site
  module Content
    class Page < Site::Struct
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

      def content_data
        @content_data ||= ContentPipeline.call(content_md)
      end

      ContentPipeline = HTMLPipeline.new(
        convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
        node_filters: [Content::Filters::LinkableHeadingsFilter.new]
      )
      private_constant :ContentPipeline
    end
  end
end
