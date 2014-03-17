require 'spec_helper'

describe "User Profile" do

  before do
    sign_in :curator
  end

  it "should be displayed" do
    click_link "curator1@example.com"
    page.should have_content "Edit Your Profile"
  end

  it "should be editable" do
    click_link "curator1@example.com"
    click_link "Edit Your Profile"
    page.should have_xpath("//form[@action='/users/curator1@example-dot-com']")
    fill_in 'user_twitter_handle', with: 'curatorOfData'
    click_button 'Save Profile'
    page.should have_content "Your profile has been updated"
    page.should have_content "curatorOfData"
  end

  it "should display all users" do
    click_link "curator1@example.com"
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1@example-dot-com']")
  end

  it "should be searchable" do
    @archivist = FactoryGirl.find_or_create(:archivist)
    click_link "curator1@example.com"
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1@example-dot-com']")
    page.should have_xpath("//td/a[@href='/users/archivist1@example-dot-com']")
    fill_in 'user_search', with: 'archivist1@example.com'
    click_button "user_submit"
    page.should_not have_xpath("//td/a[@href='/users/curator1@example-dot-com']")
    page.should have_xpath("//td/a[@href='/users/archivist1@example-dot-com']")
  end
end
