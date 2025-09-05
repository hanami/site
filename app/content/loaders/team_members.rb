# frozen_string_literal: true

require "front_matter_parser"

module Site
  module Content
    module Loaders
      class TeamMembers
        TeamMemberData = Data.define(:name, :location, :active_since, :url, :github_user, :team)

        include Deps[team_members_relation: "relations.team_members"]

        def call(root: TEAM_MEMBERS_PATH)
          root.glob("**/*.md").each do |team_member_path|
            parsed_file = FrontMatterParser::Parser.parse_file(team_member_path)
            front_matter = parsed_file.front_matter.transform_keys(&:to_sym)

            team_member = TeamMemberData.new(
              name: front_matter.fetch(:name),
              location: front_matter.fetch(:location),
              active_since: front_matter[:active_since],
              url: front_matter[:url],
              github_user: front_matter.fetch(:github_user),
              team: front_matter.fetch(:team)
            )

            team_members_relation.insert(team_member.to_h)
          end
        end
      end
    end
  end
end
