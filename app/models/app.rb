class App < ApplicationRecord
  has_many :users
  belongs_to :user, foreign_key: :owner_id

  alias_method :owner, :user

  def attributes_for_api
    {id: public_id}.merge(self.slice(:name, :config, :public_data, :created_at, :updated_at))
  end

end
