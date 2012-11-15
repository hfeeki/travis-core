require 'active_record'

# Models an incoming request. The only supported source for requests currently is Github.
#
# The Request will be configured by fetching `.travis.yml` from the Github API
# and needs to be approved based on the configuration. Once approved the
# Request creates a Build.
class Request < ActiveRecord::Base
  autoload :Approval, 'travis/model/request/approval'
  autoload :Branches, 'travis/model/request/branches'
  autoload :States,   'travis/model/request/states'

  include States

  class << self
    def last_by_head_commit(head_commit)
      where(head_commit: head_commit).order(:id).last
    end
  end

  belongs_to :commit
  belongs_to :repository
  belongs_to :owner, polymorphic: true
  has_many   :builds
  has_many   :events, as: :source

  validates :repository_id, presence: true

  serialize :config
  serialize :payload

  def event_type
    read_attribute(:event_type) || 'push'
  end

  def pull_request?
    event_type == 'pull_request'
  end

  def config_url
    "https://api.github.com/repos/#{repository.slug}/contents/.travis.yml?ref=#{commit.commit}"
  end

  def save!(*)
    super
  rescue ActiveRecord::RecordInvalid => e
    Travis.logger.error "Build:#{id} failed because of the following errors: #{collect_errors(self).join(', ')}"
    raise
  end

  private

  def collect_errors(object)
    errors = object.errors
    messages = errors.to_a.map do |message|
      str = object.class.name.dup
      str << ":#{object.id}" if object.respond_to?(:id) && object.id
      str << ": #{message}"
      str
    end

    errors.keys.each do |key|
      value = object.send(key)
      value = [value] unless value.respond_to?(:each)

      value.each do |v|
        next unless v.respond_to?(:errors)

        messages += collect_errors(v)
      end
    end

    messages
  end
end
