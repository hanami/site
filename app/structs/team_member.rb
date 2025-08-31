# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

module Site
  module Structs
    class TeamMember < Site::DB::Struct
      def active?
        !active_since.nil?
      end

      def status
        active? ? "Active since #{active_since}" : "Former member"
      end

      def description_md
        description
      end

      def description_html
        @description_html ||= description_data.fetch(:output).html_safe
      end

      private

      ContentPipeline = HTMLPipeline.new(
        convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new
      )
      private_constant :ContentPipeline

      def description_data
        @description_data ||= ContentPipeline.call(description_md)
      end
    end
  end
end
