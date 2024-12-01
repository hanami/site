# frozen_string_literal: true

module Site
  module Content
    # Loads guides from content/guides/ into the database.
    class LoadGuides
      include Deps[relation: "relations.guides"]

      def call(root: GUIDES_PATH)
        # Prepare an array of paths like "hanami/v2.2/views".
        guide_paths = root.glob("*/*/*").map { _1.relative_path_from(root).to_s }

        guide_paths.each do |guide_path|
          org, version, slug = guide_path.split("/")

          relation.insert(org:, slug:, version:)
        end
      end
    end
  end
end
