require 'travis/services'

module Travis
  module Github
    module Services
      class FindOrCreateOwner < Travis::Services::Base
        register :github_find_or_create_owner

        REQUIRED_PARAMS = [:type, :login]

        def initialize(*)
          super
          validate_params
        end

        def run
          run_service(:"github_find_or_create_#{type}", login: params[:login])
        end

        private

          def type
            params[:type] == 'User' ? 'user' : 'org'
          end

          def validate_params
            missing = REQUIRED_PARAMS.select { |key| params[key].blank? }
            raise_params_missing(missing) unless missing.empty?
            raise_invalid_type unless params[:type] == 'User' || params[:type] == 'Organization'
          end

          def raise_params_missing(missing)
            raise ArgumentError, "params missing: #{missing.join(', ')}, given params: #{params.inspect}"
          end

          def raise_invalid_type
            raise ArgumentError, %(params[:type] needs to be either "User" or "Organization", but is: #{params[:type].inspect})
          end
      end
    end
  end
end
