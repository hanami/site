# frozen_string_literal: true

RSpec.feature "Guides / Guide pages" do
  it "renders a guide index page" do
    visit "/guides/hanami/v2.2/views"

    expect(page).to have_content "Guide: Views"
    expect(page).to have_content "Page: Overview"
  end

  it "renders a guide page" do
    visit "/guides/hanami/v2.2/views/context"

    expect(page).to have_content "Guide: Views"
    expect(page).to have_content "Page: Context"
  end

  it "links to all the guide's pages" do
    visit "/guides/hanami/v2.2/views"

    within "[data-testid=guide-toc]" do
      links = page.find_all("a")

      expect(links[0..2].map(&:text)).to eq [
        "Overview",
        "Working with dependencies",
        "Input and exposures"
      ]

      expect(links[0][:href]).to eq "/guides/hanami/v2.2/views"
      expect(links[1][:href]).to eq "/guides/hanami/v2.2/views/working-with-dependencies"
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

    within "[data-testid=page-toc]" do
      expect(page).to have_link "Standard context", href: "#standard-context"
    end
    heading_anchor = page.find("h2", exact_text: "Standard context").find("a")
    expect(heading_anchor[:href]).to eq "#standard-context"
  end

  it "links to the other guides, in correct order" do
    visit "/guides/hanami/v2.2/views"

    within "[data-testid=guides-list]" do
      all_guide_names = page.find_all("li a").map(&:text)

      expect(all_guide_names[0..2]).to eq [
        "Getting started",
        "Command line",
        "App"
      ]
    end
  end

  it "replaces //page URLs with URLs within the current guide and version" do
    visit "/guides/hanami/v2.2/actions"

    within ".content" do
      # In the markdown, this is linked as "//page/parameters"
      expect(page).to have_link "parameters", href: "/guides/hanami/v2.2/actions/parameters"
    end
  end

  it "transforms //guide links into links to a different guide within the current version" do
    visit "/guides/hanami/v2.2/getting-started/building-a-web-app"

    within ".content" do
      # In the markdown, this is linked as "//guide/actions"
      expect(page).to have_link "Actions guide", href: "/guides/hanami/v2.2/actions"
    end
  end
end
