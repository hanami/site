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

  it "shows a list of all the guide's pages" do
    visit "/guides/hanami/v2.2/views"

    within "[data-testid=guide-toc]" do
      expect(page).to have_selector "li:nth-child(1)", text: "Overview"
      expect(page).to have_selector "li:nth-child(2)", text: "Context"
    end
  end

  it "shows a table of contents for the current page" do
    visit "/guides/hanami/v2.2/views/context"

    within "[data-testid=page-toc]" do
      expect(page).to have_selector "li:nth-child(1)", text: "Standard context"
      expect(page).to have_selector "li:nth-child(2)", text: "Customizing the standard context"
      expect(page).to have_selector "li:nth-child(3)", text: "Decorating context attributes"
      expect(page).to have_selector "li:nth-child(4)", text: "Providing an alternative context object"
    end
  end

  it "links to the other guides, in correct order" do
    visit "/guides/hanami/v2.2/views"

    within "[data-testid=guides-list]" do
      all_guide_names = page.find_all("li a").map(&:text)

      expect(all_guide_names[0..2]).to eq [
        "guides/hanami/v2.2/getting-started",
        "guides/hanami/v2.2/command-line",
        "guides/hanami/v2.2/app"
      ]
    end
  end
end
