require 'spec_helper'

describe Travis::Github::Services::FindOrCreateRepo do
  include Travis::Testing::Stubs

  let(:owner)   { stub_user }
  let(:params)  { { owner: owner, name: 'name' } }
  let(:service) { described_class.new(nil, params) }

  before :each do
    Repository.stubs(:create!).returns(repo)
    repo.stubs(:update_attributes)
  end

  it 'tries to find an existing repo using the :find_repo service' do
    service.expects(:run_service).with(:find_repo, owner_name: 'svenfuchs', name: 'name').returns(repo)
    service.run
  end

  it 'updates the repo attributes if a repo was found' do
    service.stubs(:run_service).with(:find_repo, is_a(Hash)).returns(repo)
    repo.stubs(:update_attributes).with(owner: owner, owner_name: 'svenfuchs', name: 'name')
    service.run
  end

  it 'creates a new repo with the given owner_name, name and owner attributes if no repo could be found' do
    service.stubs(:run_service).with(:find_repo, is_a(Hash))
    Repository.expects(:create!).returns(repo)
    service.run
  end

  describe 'it validates params' do
    it 'raises on missing owner' do
      params.delete(:owner)
      -> { service.run }.should raise_error(ArgumentError) { |error| error.message.should include('params missing: owner') }
    end

    it 'raises on missing name' do
      params.delete(:name)
      -> { service.run }.should raise_error(ArgumentError) { |error| error.message.should include('params missing: name') }
    end

    it 'raises on wrong owner type' do
      params.update(owner: 'owner')
      -> { service.run }.should raise_error(ArgumentError) { |error| error.message.should include('params[:owner] needs to be a User or Organization') }
    end
  end
end
