require 'spec_helper'

describe Request do
  include Support::ActiveRecord

  let(:repo)    { Repository.new(owner_name: 'travis-ci', name: 'travis-ci') }
  let(:commit)  { Commit.new(commit: '12345678') }
  let(:request) { Request.new(repository: repo, commit: commit) }

  describe 'config_url' do
    it 'returns the raw url to the .travis.yml file on github' do
      request.config_url.should == 'https://api.github.com/repos/travis-ci/travis-ci/contents/.travis.yml?ref=12345678'
    end
  end

  it 'logs the errors on failed attempt to save!' do
    job   = Factory.build(:test, repository_id: nil)
    build = Factory.build(:build, matrix: [job], repository_id: nil)

    job.should_not be_valid
    build.should_not be_valid

    request = Factory.build(:request, builds: [build])

    Travis.logger.expects(:error).with(
      "Build: failed because of the following errors: Request: Builds is invalid, Build: Matrix is invalid, Build: Repository can't be blank, Job::Test: Repository can't be blank"
    )

    expect {
      request.save!
    }.to raise_error(ActiveRecord::RecordInvalid)
  end


end
