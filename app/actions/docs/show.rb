# frozen_string_literal: true

module Site
  module Actions
    module Docs
      class Show < Site::Action
        INDEX_PAGE_PATH = Content::INDEX_PAGE_PATH

        include Deps["repos.doc_repo"]

        def handle(request, response)
          # Return 404 when index name is explicitly given, since we use this for the doc's root.
          halt 404 if request.params[:path] == INDEX_PAGE_PATH

          # When no path is given, we're at the doc's root. Here we can set the path to index to
          # render the doc's index page.
          params = request.params.to_h
          params[:path] ||= INDEX_PAGE_PATH

          response.render(view, **params)
        rescue Content::NotFoundError => e
          raise Action::NotFoundError, "#{e.path} not found"
        end
      end
    end
  end
end
