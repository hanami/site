# frozen_string_literal: true

require "html_pipeline"

module Site
  module Content
    module Filters
      # Replaces internal links with the format "//_link_type/some/extra/path".
      #
      # Expects an `:internal_links` hash to be provided in the context, with a transformation proc
      # for each link type. Based on the above example, the following context should be provided:
      #
      # ```
      # context: {
      #   internal_links: {
      #     link_type: ->(path) {
      #       # transform the path here
      #     }
      #   }
      # }
      # ```
      class InternalLinksFilter < HTMLPipeline::NodeFilter
        SELECTOR = Selma::Selector.new(match_element: "a")

        def selector = SELECTOR

        def after_initialize
          result[:internal_links] ||= {}
        end

        def handle_element(element)
          href = element["href"]

          begin
            uri = URI.parse(href)
          rescue
            return
          end

          link_type = uri.host

          return unless link_type&.start_with?("_")

          replacement_proc = internal_links[link_type.sub(/^_/, "").to_sym]

          return unless replacement_proc

          element["href"] = replacement_proc.call(uri.path)
        end

        private

        def internal_links = context[:internal_links]
      end
    end
  end
end
