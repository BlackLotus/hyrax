RSpec.describe Hyrax::AdminSetPresenter do
  let(:admin_set) do
    mock_model(AdminSet,
               id: '123',
               description: ['An example admin set.'],
               title: ['Example Admin Set Title'])
  end

  let(:work) { build(:work, title: ['Example Work Title']) }
  let(:solr_document) { SolrDocument.new(admin_set.to_solr) }
  let(:ability) { double }
  let(:presenter) { described_class.new(solr_document, ability) }

  describe "total_items" do
    subject { presenter.total_items }
    let(:admin_set) { build(:admin_set) }

    context "empty admin set" do
      it { is_expected.to eq 0 }
    end

    context "admin set with work" do
      let(:admin_set) { create(:admin_set, members: [work]) }
      it { is_expected.to eq 1 }
    end
  end

  describe "disable_delete?" do
    subject { presenter.disable_delete? }

    context "empty admin set" do
      let(:admin_set) { create(:admin_set) }
      it { is_expected.to be false }
    end

    context "non-empty admin set" do
      let(:admin_set) { create(:admin_set, members: [work]) }
      it { is_expected.to be true }
    end

    context "default admin set" do
      let(:admin_set) do
        build(:admin_set, id: AdminSet::DEFAULT_ID)
      end
      it { is_expected.to be true }
    end
  end
end
