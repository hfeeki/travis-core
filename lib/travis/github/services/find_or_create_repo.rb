module Travis
  module Github
    module Services
      class FindOrCreateRepo < Travis::Services::Base
        register :github_find_or_create_repo

        REQUIRED_PARAMS = [:owner, :name]

        def initialize(*)
          super
          validate_params
        end

        def run
          repo = find || create
          repo.update_attributes(attributes)
          repo
        end

        private

          def find
            run_service(:find_repo, owner_name: owner.login, name: params[:name])
          end

          def create
            Repository.create!(attributes)
          end

          def attributes
            { owner: owner, owner_name: owner.login, name: params[:name] }
          end

          def owner
            params[:owner]
          end

          def validate_params
            missing = REQUIRED_PARAMS.select { |key| params[key].blank? }
            raise_params_missing(missing) unless missing.empty?
            raise_invalid_owner unless owner.is_a?(User) || owner.is_a?(Organization)
          end

          def raise_params_missing(missing)
            raise ArgumentError, "params missing: #{missing.join(', ')}, given params: #{params.inspect}"
          end

          def raise_invalid_owner
            raise ArgumentError, "params[:owner] needs to be a User or Organization, but is: #{params[:owner].inspect}"
          end
      end
    end
  end
end

