# frozen_string_literal: true

module Site
  module Repos
    class TeamMemberRepo < Site::DB::Repo
      def all
        team_members.to_a
      end
    end
  end
end
