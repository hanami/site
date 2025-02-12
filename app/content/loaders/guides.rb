# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads guides from content/guides/ into the database.
      class Guides
        GuideData = Data.define(:org, :slug, :title, :version)

        GUIDES_YML = "guides.yml"
        GUIDES_KEY = :guides
        SLUG_KEY = :slug
        TITLE_KEY = :title

        include Deps[relation: "relations.guides"]

        def call(root: GUIDES_PATH)
          # Find all per-org guide versions: ["hanami/v2.2", ...]
          org_versions = root.glob("*/*").map { it.relative_path_from(root).to_s }

          # For each versioned set of guides, load the available guides (in order) from guides.yml
          guides = org_versions.each_with_object([]) { |org_version, memo_arr|
            guides_yml = GUIDES_PATH.join(org_version, GUIDES_YML)
            next unless guides_yml.file?

            org, version = org_version.split(File::SEPARATOR)

            versioned_guides = File.read(guides_yml)
              .then { YAML.load(it, symbolize_names: true) }
              .fetch(GUIDES_KEY)
              .map { |guide_attrs|
                GuideData.new(
                  org:, version:,
                  slug: guide_attrs.fetch(SLUG_KEY),
                  title: guide_attrs.fetch(TITLE_KEY)
                )
              }

            memo_arr.concat versioned_guides
          }

          # Insert a record for each guide
          guides.each_with_index do |guide, position|
            relation.insert(**guide.to_h, position:)
          end
        end
      end
    end
  end
end
