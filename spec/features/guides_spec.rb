# frozen_string_literal: true

RSpec.feature "Guides" do
  it "renders a guide index page" do
    visit "/guides/hanami/v2.2/views"

    expect(page).to have_content "Guide: views"
    expect(page).to have_content "Page: Overview"
  end

  it "renders a guide page" do
    visit "/guides/hanami/v2.2/views/context"

    expect(page).to have_content "Guide: views"
    expect(page).to have_content "Page: Context"
  end

  it "shows a list of a guide's pages" do
    visit "/guides/hanami/v2.2/views"

    within("[data-testid=guide-toc]") do
      expect(page).to have_selector "li:nth-child(1)", text: "Overview"
      expect(page).to have_selector "li:nth-child(2)", text: "Context"
    end
  end
end
