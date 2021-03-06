require 'travis/sidekiq/synchronize_user'

module Travis
  module Services
    class SyncUser < Base
      register :sync_user

      def run
        trigger_sync unless user.syncing?
      end

      def trigger_sync
        if Travis::Features.user_active?(:sync_via_sidekiq, user) or Travis::Features.enabled_for_all?(:sync_via_sidekiq)
          logger.info("Synchronizing via Sidekiq for user: #{user.login}")
          Travis::Sidekiq::SynchronizeUser.perform_async(user.id)
        else
          logger.info("Synchronizing via AMQP for user: #{user.login}")
          publisher.publish({ :user_id => user.id }, :type => 'sync')
        end
        user.update_column(:is_syncing, true)
        true
      end

      def user
        # TODO check that clients are only passing the id
        @user ||= current_user || User.find(params[:id])
      end

      def publisher
        Travis::Amqp::Publisher.new('sync.user')
      end
    end
  end
end
