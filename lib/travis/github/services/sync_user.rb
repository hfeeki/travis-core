module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        autoload :Organizations, 'travis/github/services/sync_user/organizations'
        autoload :Repositories,  'travis/github/services/sync_user/repositories'
        autoload :Repository,    'travis/github/services/sync_user/repository'

        register :github_sync_user

        def run
          syncing do
            with_github do |gh|
              Organizations.new(user, gh).run
              Repositories.new(user, gh).run
            end
          end
        end

        def user
          # TODO check that clients are only passing the id
          @user ||= current_user || User.find(params[:id])
        end

        private

          def with_github(&block)
            gh = GH::Stack.new do
              use GH::Instrumentation
              use GH::Parallel
              use GH::Pagination
              use GH::LinkFollower
              use GH::MergeCommit
              use GH::LazyLoader
              use GH::Normalizer
              use GH::CustomLimit
              # use GH::Remote
              use GH::Cache
            end
            gh = gh.build(token: user.github_oauth_token)
            yield gh
          end

          def gh
          end

          def syncing
            user.update_column(:is_syncing, true)
            result = yield
            user.update_column(:synced_at, Time.now)
            result
          ensure
            user.update_column(:is_syncing, false)
          end
      end
    end
  end
end
