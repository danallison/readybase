# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
meta_app_id = Rails.application.config.meta_app_id
meta_app = App.where(public_id: meta_app_id).first
meta_app ||= App.new(name: 'ReadyBase', public_id: meta_app_id, owner_id: 0)
meta_app.apply_defaults # calling this manually since we are skipping validations
meta_app.save(validate: false) # owner_id: 0 is not valid, so skipping validation
puts "meta_app found or created"
meta_user = meta_app.users.first
meta_user ||= User.create(app_id: meta_app.id, username: 'meta_user', email: 'meta@readybase.org', password: SecureRandom.hex(4))
puts "meta_user found or created"
meta_app.owner_id = meta_user.id
meta_app.save!
puts "meta_user now owns meta_app"
