class AppObjectAssociation < ApplicationRecord
  belongs_to :app_object, foreign_key: :object_id
end
