# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

module Site
  module Structs
    class Post < Site::DB::Struct
      def url_path
        "/blog/#{permalink}"
      end

      def content_md
        content
      end

      def content_html
        @content_html ||= content_data.fetch(:output).html_safe
      end

      def excerpt
        self[:excerpt] || "TODO"
      end

      private

      ContentPipeline = HTMLPipeline.new(
        convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
        node_filters: [
          Content::Filters::LinkableHeadingsFilter.new
        ]
      )
      private_constant :ContentPipeline

      def content_data
        @content_data ||= ContentPipeline.call(content_md)
      end
    end
  end
end
