class Person < ActiveRecord::Base
  attr_accessible :family_name, :full_name, :given_name, :user_id, :preferred_style, :preferred_locale
  has_many :sources

  after_initialize :default_values 

  private
  	def default_values
  	  #logger.info('Person.default_values')

  	  self.preferred_style ||= Citations::Application.config.default_style
  	  #logger.info(self.preferred_style)

  	end
end
