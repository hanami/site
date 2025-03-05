# frozen_string_literal: true

module Site
  module Views
    module Docs
      class Index < Site::View
        include Deps["repos.doc_repo"]

        expose :docs do
          doc_repo.latest_by_org
        end
      end
    end
  end
end
