module Travis
  module Services
    class FindJobs < Base
      register :find_jobs

      def run
        preload(result)
      end

      private

        def result
          @result ||= params[:ids] ? by_ids : by_params
        end

        def by_ids
          scope(:job).where(:id => params[:ids])
        end

        def by_params
          scope(:job).queued(params[:queue])
        end

        def preload(jobs)
          jobs = jobs.includes(:commit)
          ActiveRecord::Associations::Preloader.new(jobs, :log, :select => [:id, :job_id]).run
          ActiveRecord::Associations::Preloader.new(jobs, :repository, :select => [:id, :owner_name, :name]).run
          jobs
        end
    end
  end
end
