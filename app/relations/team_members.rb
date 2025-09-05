# frozen_string_literal: true

module Site
  module Relations
    class TeamMembers < Hanami::DB::Relation
      schema :team_members do
        attribute :name, Types::Nominal::String
        attribute :location, Types::Nominal::String
        attribute :active_since, Types::Nominal::Integer.optional
        attribute :url, Types::Nominal::String.optional
        attribute :github_user, Types::Nominal::String
        attribute :team, Types::Nominal::String
      end
    end
  end
end
