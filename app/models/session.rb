class Session < ApplicationRecord
  has_secure_token
  belongs_to :app
  belongs_to :user

  def self.unique_id_prefix
    's'
  end

  def attributes_for_api
    {id: unique_id}.merge(self.slice(:user_agent, :created_at))
  end

  def pulic_attributes_for_api
    raise 'sessions are not public'
  end
end
