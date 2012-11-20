class ZoteroItem < ActiveResource::Base

  #self.site = "http://127.0.0.1:1337/"
  self.site = "https://api.zotero.org"
  self.element_name = "items"

  self.source_type = "zotero"

  schema do
    attribute 'abstract', :string 
    attribute 'annote', :string
    attribute 'archive',  :string 
    attribute 'archive_location',  :string 
    attribute 'archive-place', :string 
    attribute 'authority',  :string 
    attribute 'call-number',  :string 
    attribute 'chapter-number', :string 
    attribute 'citation-label',  :string 
    attribute 'citation-number',  :string 
    attribute 'collection-title',  :string 
    attribute 'container-title',  :string 
    attribute 'DOI',  :string 
    attribute 'edition',  :string 
    attribute 'event',  :string 
    attribute 'event-place',  :string 
    attribute 'first-reference-note-number',  :string 
    attribute 'genre',  :string 
    attribute 'ISBN',  :string 
    attribute 'issue',  :string 
    attribute 'jurisdiction',  :string 
    attribute 'keyword',  :string 
    attribute 'locator',  :string 
    attribute 'medium',  :string 
    attribute 'note',  :string 
    attribute 'number',  :string 
    attribute 'number-of-pages',  :string 
    attribute 'number-of-volumes',  :string 
    attribute 'original-publisher',  :string 
    attribute 'original-publisher-place',  :string 
    attribute 'original-title',  :string 
    attribute 'page',  :string 
    attribute 'page-first',  :string 
    attribute 'publisher',  :string 
    attribute 'publisher-place',  :string 
    attribute 'references',  :string 
    attribute 'section',  :string 
    attribute 'status',  :string 
    attribute 'title',  :string 
    attribute 'URL',  :string 
    attribute 'version',  :string 
    attribute 'volume',  :string 
    attribute 'year-suffix',  :string 
    attribute 'accessed',  :string 
    attribute 'container',  :string 
    attribute 'event-date',  :string 
    attribute 'issued',  :string 
    attribute 'original-date',  :string 
    attribute 'author',  :string 
    attribute 'editor',  :string 
    attribute 'translator',  :string 
    attribute 'recipient',  :string 
    attribute 'interviewer',  :string 
    attribute 'publisher',  :string 
    attribute 'composer',  :string 
    attribute 'original-publisher',  :string 
    attribute 'original-author',  :string 
    attribute 'container-author',  :string 
    attribute 'collection-editor',  :string 
  end
  
  # schema do 
  #   string 'abstract', 'annote', 'archive', 'archive_location', 'archive-place', 
  #     'authority', 'call-number', 'chapter-number','citation-label', 'citation-number', 
  #     'collection-title', 'container-title', 'DOI', 'edition', 'event', 'event-place', 
  #     'first-reference-note-number', 'genre', 'ISBN', 'issue', 'jurisdiction', 'keyword', 
  #     'locator', 'medium', 'note', 'number', 'number-of-pages', 'number-of-volumes', 
  #     'original-publisher', 'original-publisher-place', 'original-title', 'page', 
  #     'page-first', 'publisher', 'publisher-place', 'references', 'section', 'status', 
  #     'title', 'URL', 'version', 'volume', 'year-suffix', 'accessed', 'container', 
  #     'event-date', 'issued', 'original-date', 'author', 'editor', 'translator', 
  #     'recipient', 'interviewer', 'publisher', 'composer', 'original-publisher', 
  #     'original-author', 'container-author', 'collection-editor'
  # end

  ZoteroItem.format = ActiveResource::Formats::ZoteroXmlFormat
  ZoteroItem.include_root_in_json = true

  DATE_FIELDS = [ 'accessed', 'container', 'event-date', 'issued', 'original-date' ]
  NAME_FIELDS = [ 'author','editor','translator','recipient','interviewer','composer','original-author','container-author','collection-editor' ]

  def as_json(options = {})
    #debugger
    # ,'publisher','original-publisher'

    hsh = {}
    @attributes.each { |name, value| 
      case 
      when DATE_FIELDS.include?(name)
        hsh[name] = ZoteroItem.processDateField(value)
      when NAME_FIELDS.include?(name)
        hsh[name] = ZoteroItem.processNameField(value)      
      else
        hsh[name] = value.to_json
      end
      if name == 'id'
        @id = value
      end
    }
    return hsh 
  end

  def ZoteroItem.processDateField(val)
    # debugger
    hsh = {}
    val.attributes.each { |name, value| 
      hsh[name] = value.to_json
    }
    return hsh
  end

  def ZoteroItem.processEmbeddedDateField(val)
    #debugger
    #Rails.logger.info("processEmbeddedDateField( #{val} ) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ")

    return val.attributes
  end

  def ZoteroItem.processNameField(val)
    list = []
    # debugger
    val.each{ |item|
      hsh = {}
      item.attributes.each { |name, value| 
        hsh[name] = value.to_json
      }
      list.push(hsh)
    }
    return list
  end

  def ZoteroItem.processEmbeddedNameField(val)

    # debugger
    list = []
    #Rails.logger.info("processEmbeddedNameField( #{val} ) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ")
    val.each{ |item| 
      list.push item.attributes
    }
    return list
    #return val.attributes
  end

  def ZoteroItem.cslFormat(citations = []) 
    formatted_citations = []
    #Rails.logger.info('================ ZoteroItem.cslFormat() ===================')
 
    citations.each { |citation|
      formatted_citation = {}
      citation.attributes.each{ |name, value|
        #Rails.logger.info(name)
        case 
        when DATE_FIELDS.include?(name.to_s)
          formatted_citation[name] = ZoteroItem.processEmbeddedDateField(value)
        when NAME_FIELDS.include?(name.to_s)
          formatted_citation[name] = ZoteroItem.processEmbeddedNameField(value)      
        else
          formatted_citation[name] = value.to_json
        end

      }
      formatted_citations.push(formatted_citation)
      ##Rails.logger.info(formatted_citation.to_json.to_s)
      #Rails.logger.info('---------------- ZoteroItem.cslFormat() -------------------')

    }
    rv = {}
    rv[:items] = formatted_citations
    #rv[:citationItems] = formatted_citations
    ##Rails.logger.info(rv)
    #Rails.logger.info('================ ZoteroItem.cslFormat() ===================')
    return rv
  end


end
