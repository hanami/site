# frozen_string_literal: true

module Site
  module Actions
    module Guides
      class Show < Site::Action
        def handle(request, response)
          # Return 404 when "index" path is given explicitly, since we use this for the guide root.
          halt 404 if request.params[:path] == "index"

          # When no path is given, we're at the guide's root. Now we can set the path to "index" in
          # order to render the index page.
          params = request.params.to_h
          params[:path] ||= "index"

          response.render(view, **params)
        rescue Content::NotFoundError => e
          raise Action::NotFoundError, "#{e.path} not found"
        end
      end
    end
  end
end
