# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads gems and docs from content/docs/ into the database.
      class GemsDocs
        GemData = Data.define(:org, :slug, :hidden)
        DocData = Data.define(:org, :slug, :version, :hidden)

        YAML_PATH = "docs.yml"
        DOCS_KEY = :docs
        SLUG_KEY = :slug
        HIDDEN_KEY = :hidden

        include Deps[
          docs_relation: "relations.docs",
          gems_relation: "relations.gems"
        ]

        def call(root: DOCS_PATH)
          org_paths = root.glob("*")

          org_paths.each do |org_path|
            org = org_path.relative_path_from(root).to_s
            load_org(org:, org_path:)
          end
        end

        private

        def load_org(org:, org_path:)
          yaml_path = org_path.join(YAML_PATH)
          return unless yaml_path.file?

          yaml_docs = File.read(yaml_path)
            .then { YAML.load(it, symbolize_names: true) }
            .fetch(DOCS_KEY)

          gems = yaml_docs.map { |yaml_gem|
            GemData.new(
              org:,
              slug: yaml_gem.fetch(SLUG_KEY),
              hidden: gem_hidden?(yaml_gem[HIDDEN_KEY])
            )
          }
          gems_relation.multi_insert(gems.map(&:to_h))

          docs = yaml_docs.each_with_object([]) { |yaml_doc, memo_arr|
            slug = yaml_doc.fetch(SLUG_KEY)
            hidden_versions = hidden_versions(yaml_doc[HIDDEN_KEY])
            versions_path = org_path.join(slug)
            versions = versions_path.glob("*").map { it.relative_path_from(versions_path).to_s }

            versions.each do |version|
              memo_arr << DocData.new(
                org:, slug:, version:,
                hidden: hidden_versions.include?(version)
              )
            end
          }
          docs_relation.multi_insert(docs.map(&:to_h))
        end

        def gem_hidden?(value)
          return false if value.is_a?(Array)
          !!value
        end

        def hidden_versions(value)
          return value if value.is_a?(Array)
          []
        end
      end
    end
  end
end
