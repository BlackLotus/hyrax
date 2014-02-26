require 'spec_helper'

describe Sufia::GenericFile::ReloadOnSave do
  let(:user) { FactoryGirl.find_or_create(:user) }
  let(:file) { GenericFile.new.tap { |f| f.apply_depositor_metadata(user); f.save! } }

  it 'defaults to not call reload' do
    file.should_not_receive(:reload)
    file.save
  end

  it 'can be set to call reload' do
    file.reload_on_save = true
    file.should_receive(:reload)
    file.save
  end

  it 'allows reload to be turned off and on' do
    file.reload_on_save = true
    file.should_receive(:reload).once
    file.save
    file.reload_on_save = false
    file.save
  end
end
