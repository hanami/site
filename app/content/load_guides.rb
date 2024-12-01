# frozen_string_literal: true

module Site
  module Content
    class LoadGuides
      include Deps[relation: "relations.guides"]

      def call(root: GUIDES_PATH)
        # "hanami/v2.2/views"
        guide_paths = root.glob("*/*/*").map { _1.relative_path_from(root).to_s }

        guide_paths.each do |guide_path|
          org, version, slug = guide_path.split("/")

          relation.insert(org:, slug:, version:)
        end
      end
    end
  end
end
