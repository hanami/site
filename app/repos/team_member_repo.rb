# frozen_string_literal: true

module Site
  module Repos
    class TeamMemberRepo < Site::DB::Repo
      def all_for(team:)
        team_members.where(team:).to_a
      end
    end
  end
end
