# frozen_string_literal: true

RSpec.feature "Guides / Index page" do
  it "lists all the guides across orgs" do
    visit "/guides"

    within "[data-testid=hanami-guides]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "Getting started",
        "Command line",
        "App"
      ]
    end

    within "[data-testid=dry-rb-guides]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "Getting started"
      ]
    end

    within "[data-testid=rom-guides]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "Getting started",
        "Framework integrations",
        "Core concepts"
      ]
    end
  end
end
