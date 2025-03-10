# frozen_string_literal: true

RSpec.feature "Docs / Doc pages" do
  it "renders a doc index page" do
    visit "/docs/dry-operation/v1.0"

    expect(page).to have_content "Doc: dry-operation"
    expect(page).to have_content "Page: Introduction"
  end

  it "renders a doc page" do
    visit "/docs/dry-operation/v1.0/configuration"

    expect(page).to have_content "Doc: dry-operation"
    expect(page).to have_content "Page: Configuration"
  end

  it "links to all the doc's pages" do
    visit "/docs/dry-operation/v1.0"

    within "[data-testid=pages-nav]" do
      links = page.find_all("a")

      expect(links[0..2].map(&:text)).to eq [
        "Introduction",
        "Error Handling",
        "Configuration"
      ]

      expect(links[0][:href]).to eq "/docs/dry-operation/v1.0"
      expect(links[1][:href]).to eq "/docs/dry-operation/v1.0/error-handling"
    end
  end

  it "links to a doc's nested pages" do
    visit "/docs/dry-types/v1.7"

    within "[data-testid=pages-nav]", match: :first do
      parent_item = page.find("li", text: "Extensions")
      nested_nav = parent_item.find("ol")

      within nested_nav do
        nested_links = page.find_all("a")
        expect(nested_links[0..1].map(&:text)).to eq [
          "Maybe",
          "Monads"
        ]
      end
    end
  end

  it "shows a table of contents for the current page" do
    visit "/docs/dry-operation/v1.0"

    within "[data-testid=page-toc]" do
      expect(page).to have_selector "li:nth-child(1)", text: "Introduction"
      expect(page).to have_selector "li:nth-child(2)", text: "Basic usage"
      expect(page).to have_selector "li:nth-child(3)", text: "The step method"
      expect(page).to have_selector "li:nth-child(4)", text: "The call method"
      expect(page).to have_selector "li:nth-child(5)", text: "Handling results"

      expect(page).to have_link "Basic usage", href: "#basic-usage"
    end

    heading_anchor = page.find("h2", exact_text: "Basic usage").find("a")
    expect(heading_anchor[:href]).to eq "#basic-usage"
  end
end
