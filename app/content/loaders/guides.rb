# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads guides from content/guides/ into the database.
      class Guides
        GUIDES_YML = "guides.yml"
        GUIDES_KEY = :guides
        SLUG_KEY = :slug
        TITLE_KEY = :title

        include Deps[relation: "relations.guides"]

        def call(root: GUIDES_PATH)
          # Find all per-org guide versions: ["hanami/v2.2", ...]
          org_guide_versions = root.glob("*/*").map { it.relative_path_from(root).to_s }

          # For each versioned set of guides, load the available guides (in order) from guides.yml
          guides = org_guide_versions.each_with_object([]) { |org_guide_version, memo_arr|
            guides_yml = GUIDES_PATH.join(org_guide_version, GUIDES_YML)
            next unless guides_yml.file?

            versioned_guides = File.read(guides_yml)
              .then { YAML.load(it, symbolize_names: true) }
              .fetch(GUIDES_KEY)
              .map { it.merge(SLUG_KEY => File.join(org_guide_version, it[SLUG_KEY])) }

            memo_arr.concat versioned_guides
          }

          # Insert a record for each guide
          guides.each_with_index do |guide, position|
            org, version, slug = guide[SLUG_KEY].split("/")
            title = guide[TITLE_KEY]

            relation.insert(org:, slug:, title:, version:, position:)
          end
        end
      end
    end
  end
end
