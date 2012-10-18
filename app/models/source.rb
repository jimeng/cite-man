class Source < ActiveRecord::Base
  attr_accessible :client_id, :client_key, :client_secret, :client_type, :name, :person_id, :provider, :uid, :default_style
  belongs_to :person

  after_initialize :default_values 

  def items_link 
    logger.info('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
    # debugger
    logger.info('Source.items_link called.')
    logger.info("id == #{id}")
    logger.info("provider == #{provider}")
    target = '#citations'
    link = ''
    case provider
    when 'zotero'
      link = '/sources/' + id.to_s + '/zotero_item'
    when 'mendeley'
      link = '/sources/' + id.to_s + '/mendeley_item'
    when 'refworks'
      link = '/sources/' + id.to_s + '/refworks_item'
    else
      link = '/sources/' + id.to_s + '/items'
    end

    logger.info("uid == >#{uid}<")
    logger.info("link == #{link}")
    logger.info('Source.items_link returning.')
    return { :link => link, :target => target }
  end

  private
    def default_values
      person = Person.find(self.person_id)
      self.default_style ||= person.preferred_style || Citations::Application.config.default_style
    end
end
