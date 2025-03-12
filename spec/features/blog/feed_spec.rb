# frozen_string_literal: true

# Basic test to ensure Atom feed renders correctly.
RSpec.feature "Blog / Feed" do
  it "renders an atom feed" do
    visit "/feed.xml"

    expect(page.body).to include("<entry>").exactly(10).times
  end
end
