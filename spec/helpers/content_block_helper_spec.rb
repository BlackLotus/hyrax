require 'spec_helper'

describe ContentBlockHelper do
  let(:content_block) { FactoryGirl.create(:content_block, value: "<p>foo bar</p>") } 

  subject { helper.editable_content_block(content_block) }

  context "for someone with access" do
    before do
      expect(helper).to receive(:can?).with(:update, content_block).and_return(true)
    end
    let(:node) { Capybara::Node::Simple.new(subject) }
    it "should show the preview and the form" do
      expect(node).to have_selector "button[data-target='#edit_content_block_1'][data-behavior='reveal-editor']" 
      expect(node).to have_selector "form#edit_content_block_1[action='#{sufia.content_block_path(content_block)}']" 
      expect(subject).to be_html_safe
    end
  end

  context "for someone without access" do
    before do
      expect(helper).to receive(:can?).with(:update, content_block).and_return(false)
    end
    it "should show the content" do
      expect(subject).to eq '<p>foo bar</p>'
      expect(subject).to be_html_safe
    end
  end
end
