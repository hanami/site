# frozen_string_literal: true

module Site
  class Routes < Hanami::Routes
    # Only consider strings like "v1.0" as versions in paths
    VERSION_OPTS = {version: /v\d+\.\d+/}.freeze

    root to: "pages.home"

    get "/guides", to: "guides.index"
    get "/guides/:org/:version", to: "guides.org_index", **VERSION_OPTS
    get "/guides/:org/:version/:slug", to: "guides.show", **VERSION_OPTS
    get "/guides/:org/:version/:slug/*path", to: "guides.show", **VERSION_OPTS
    get "/guides/:org/:slug", to: "guides.redirect"
    get "/guides/:org/:slug/*path", to: "guides.redirect"

    get "/docs", to: "docs.index"
    get "/docs/:slug/:version", to: "docs.show", **VERSION_OPTS
    get "/docs/:slug/:version/*path", to: "docs.show", **VERSION_OPTS
    get "/docs/:slug", to: "docs.redirect"
    get "/docs/:slug/*path", to: "docs.redirect"

    get "/blog", to: "blog.index", as: :blog
    get "/blog/page/:page", to: "blog.index"
    get "/blog/*permalink", to: "blog.show", as: :blog_post
    get "/feed.xml", to: "feed.index"

    get "/community", to: "pages.community"
  end
end
