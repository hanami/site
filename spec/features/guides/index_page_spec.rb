# frozen_string_literal: true

RSpec.feature "Guides / Index page" do
  it "lists all the guides and versions across orgs" do
    visit "/guides"

    within "[data-testid=hanami-guides]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "Getting started",
        "Command line",
        "App"
      ]
    end

    within "[data-testid=hanami-versions]" do
      expect(page).to have_link "v2.1"
      expect(page).to have_link "v2.0"
      expect(page).to have_link "v2.2"

      expect(page.find_link("v2.1")[:href]).to eq "/guides/hanami/v2.1"
    end

    within "[data-testid=dry-rb-guides]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "Getting started"
      ]
    end

    within "[data-testid=rom-guides]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "Getting started"
      ]
    end
  end
end
