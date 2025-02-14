# frozen_string_literal: true

module Site
  module Actions
    module Guides
      class Show < Site::Action
        INDEX_NAME = Content::INDEX_NAME

        def handle(request, response)
          # Return 404 when index name is explicitly given, since we use this for the guide's root.
          halt 404 if request.params[:path] == INDEX_NAME

          # When no path is given, we're at the guide's root. Here we can set the path to index to
          # render the guide's index page.
          params = request.params.to_h
          params[:path] ||= INDEX_NAME

          response.render(view, **params)
        rescue Content::NotFoundError => e
          raise Action::NotFoundError, "#{e.path} not found"
        end
      end
    end
  end
end
