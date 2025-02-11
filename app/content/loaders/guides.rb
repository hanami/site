# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads guides from content/guides/ into the database.
      class Guides
        GUIDES_YML = "guides.yml"
        GUIDES_KEY = :guides

        include Deps[relation: "relations.guides"]

        def call(root: GUIDES_PATH)
          # Find all per-org guide versions: ["hanami/v2.2", ...]
          org_guide_versions = root.glob("*/*").map { it.relative_path_from(root).to_s }

          # For each versioned set of guides, load the available guides (in order) from guides.yml
          guide_paths = org_guide_versions.each_with_object([]) { |org_guide_version, memo_arr|
            guides_yml = GUIDES_PATH.join(org_guide_version, GUIDES_YML)
            next unless guides_yml.file?

            versioned_guides = File.read(guides_yml)
              .then { YAML.load(it, symbolize_names: true) }
              .fetch(GUIDES_KEY)
              .map { File.join(org_guide_version, it) }

            memo_arr.concat versioned_guides
          }

          # Insert a record for each guide
          guide_paths.each_with_index do |guide_path, position|
            org, version, slug = guide_path.split("/")

            relation.insert(org:, slug:, version:, position:)
          end
        end
      end
    end
  end
end
