require 'active_support/core_ext/string/filters'

class Artifact::Part < ActiveRecord::Base
  # TODO stop ordering by id once workers pass the part number
  AGGREGATE_SELECT_SQL = <<-sql.squish
    SELECT array_to_string(array_agg(artifact_parts.content ORDER BY number, id), '')
      FROM artifact_parts
     WHERE artifact_id = ?
  sql

  AGGREGATE_UPDATE_SQL = <<-sql.squish
    UPDATE artifacts
       SET aggregated_at = ?,
           content = (COALESCE(content, '') || (#{AGGREGATE_SELECT_SQL}))
     WHERE artifacts.id = ?
  sql

  self.table_name = 'artifact_parts'

  class << self
    def aggregate(artifact_id)
      connection.execute(sanitize_sql([AGGREGATE_UPDATE_SQL, Time.now, artifact_id, artifact_id]))
    end
  end
end

