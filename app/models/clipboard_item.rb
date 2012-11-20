class ClipboardItem < ActiveRecord::Base
  attr_accessible :citation, :citation_id, :person_id
  belongs_to :person
end
