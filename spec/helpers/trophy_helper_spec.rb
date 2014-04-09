require 'spec_helper'

describe TrophyHelper do
  describe "#display_trophy_link" do
    let(:user) { FactoryGirl.create(:normal_user) }
    let(:noid) { '9999' }

    let(:text_attributes) { '[data-add-text="Highlight File on Profile"][data-remove-text="Unhighlight File"]' }
    let(:url_attribute) { "[data-url=\"/users/#{user.to_param}/trophy?file_id=9999\"]" }

    context "when there is no trophy" do
      it "should have a link for highlighting" do
        out = helper.display_trophy_link(user, noid) { |text| "foo #{text} bar" } 
        node = Capybara::Node::Simple.new(out)
        expect(node).to have_selector("a.trophy-class.trophy-off#{text_attributes}#{url_attribute}")
        expect(node).to have_link 'foo Highlight File on Profile bar', href: '#'
      end
    end

    context "when there is a trophy" do
      before do
        user.trophies.create(generic_file_id: noid)
      end

      it "should have a link for highlighting" do
        out = helper.display_trophy_link(user, noid) { |text| "foo #{text} bar" } 
        node = Capybara::Node::Simple.new(out)
        expect(node).to have_selector("a.trophy-class.trophy-on#{text_attributes}#{url_attribute}")
        expect(node).to have_link 'foo Unhighlight File bar', href: '#'
      end

      it "should allow removerow to be passed" do
        out = helper.display_trophy_link(user, noid, data: {removerow: true}) { |text| "foo #{text} bar" } 
        node = Capybara::Node::Simple.new(out)
        expect(node).to have_selector("a.trophy-class.trophy-on[data-removerow=\"true\"]#{text_attributes}#{url_attribute}")
      end
    end
  end
end
