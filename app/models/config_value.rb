class ConfigValue < ActiveRecord::Base
  attr_accessible :name, :source_type, :value
end
