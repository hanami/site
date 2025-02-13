# frozen_string_literal: true

RSpec.feature "Guides / Org index page" do
  it "renders the guides for an org at a specific version, with links to the other versions" do
    visit "/guides/hanami/v2.0"

    within "[data-testid=versions]" do
      expect(page).to have_link "v2.1"
      expect(page).to have_link "v2.0"
      expect(page).to have_link "v2.2"

      expect(page.find_link("v2.1")[:href]).to eq "/guides/hanami/v2.1"
    end

    within "[data-testid=guides]" do
      guide_links = page.find_all("li a")

      expect(guide_links[0..2].map(&:text)).to eq [
        "Getting started",
        "Command line",
        "App"
      ]

      expect(guide_links.first[:href]).to eq "/guides/hanami/v2.0/getting-started"
    end
  end
end
