# frozen_string_literal: true

require "front_matter_parser"

module Site
  module Content
    module Loaders
      class TeamMembers
        TeamMemberData = Data.define(:name, :description, :location, :active_since)

        include Deps[team_members_relation: "relations.team_members"]

        def call(root: TEAM_MEMBERS_PATH)
          root.glob("**/*.md").each do |team_member_path|
            parsed_file = FrontMatterParser::Parser.parse_file(team_member_path)
            front_matter = parsed_file.front_matter.transform_keys(&:to_sym)

            team_member = TeamMemberData.new(
              name: front_matter.fetch(:name),
              description: parsed_file.content,
              location: front_matter.fetch(:location),
              active_since: front_matter[:active_since]
            )

            team_members_relation.insert(team_member.to_h)
          end
        end
      end
    end
  end
end
