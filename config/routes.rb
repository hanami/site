# frozen_string_literal: true

module Site
  class Routes < Hanami::Routes
    root to: "pages.home"

    get "/guides", to: "guides.index"
    get "/guides/:org/:version/:slug", to: "guides.show"
    get "/guides/:org/:version/:slug/:path", to: "guides.show"

    get "/community", to: "pages.community"
  end
end
