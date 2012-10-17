class Person < ActiveRecord::Base
  attr_accessible :family_name, :full_name, :given_name, :user_id, :preferred_style, :preferred_locale
  has_many :sources
end
