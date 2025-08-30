# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      class TeamMembers
        TeamMemberData = Data.define(:name, :description, :location, :active_since)

        include Deps[team_members_relation: "relations.team_members"]

        def call(root: CONTENT_PATH)
          team_members_file = root.join("team_members.yml")
          return unless team_members_file.exist?

          team_members_data = YAML.safe_load(team_members_file.read, symbolize_names: true)
          
          team_members_data.each do |member_data|
            team_member = TeamMemberData.new(
              name: member_data.fetch(:name),
              description: member_data.fetch(:description),
              location: member_data.fetch(:location),
              active_since: member_data[:active_since]
            )

            team_members_relation.insert(team_member.to_h)
          end
        end
      end
    end
  end
end