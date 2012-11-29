require 'spec_helper'

describe Travis::Github::Services::FindOrCreateOwner do
  include Travis::Testing::Stubs

  let(:params)  { { type: 'User', login: 'login' } }
  let(:service) { described_class.new(nil, params) }

  it 'calls the github_find_or_create_user service if the given type is "User"' do
    params.update(type: 'User')
    service.expects(:run_service).with(:github_find_or_create_user, login: 'login')
    service.run
  end

  it 'calls the github_find_or_create_org service if the given type is "Organization"' do
    params.update(type: 'Organization')
    service.expects(:run_service).with(:github_find_or_create_org, login: 'login')
    service.run
  end

  describe 'it validates params' do
    it 'raises on missing owner' do
      params.delete(:type)
      -> { service.run }.should raise_error(ArgumentError) { |error| error.message.should include('params missing: type') }
    end

    it 'raises on missing login' do
      params.delete(:login)
      -> { service.run }.should raise_error(ArgumentError) { |error| error.message.should include('params missing: login') }
    end

    it 'raises on wrong type' do
      params.update(type: 'whatnot')
      -> { service.run }.should raise_error(ArgumentError) { |error| error.message.should include('params[:type] needs to be either "User" or "Organization", but is: "whatnot"') }
    end
  end
end
