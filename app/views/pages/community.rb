# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Community < Site::View
        include Deps["repos.team_member_repo"]

        expose :core_members do
          team_member_repo.all_for(team: "core")
        end

        expose :maintainers do
          team_member_repo.all_for(team: "maintainers")
        end
      end
    end
  end
end
