# Guardar los Twitter Handles(Controles de Twitter)
class TwitterUser < ActiveRecord::Base
  # Remember to create a migration!
  has_many :tweets
end
