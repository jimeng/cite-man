class ZoteroItem < ActiveResource::Base

  #self.site = "http://127.0.0.1:1337/"
  self.site = "https://api.zotero.org"
  self.element_name = "items"

  
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
  NAME_FIELDS = [ 'author','translator','recipient','interviewer','composer','original-author','container-author','collection-editor' ]

  def as_json(options = {})
    #debugger
    # ,'publisher','original-publisher'

    hsh = {}
    @attributes.each { |name, value| 
      case 
      when DATE_FIELDS.include?(name)
        hsh[name] = processDateField(value)
      when NAME_FIELDS.include?(name)
        hsh[name] = processNameField(value)      
      else
        hsh[name] = value
      end
      if name == 'id'
        @id = value
      end
    }
    return hsh 
  end

  def processDateField(val)
    # debugger
    hsh = {}
    val.attributes.each { |name, value| 
      hsh[name] = value
    }
    return hsh
  end

  def processNameField(val)
    list = []
    # debugger
    val.each{ |item|
      hsh = {}
      item.attributes.each { |name, value| 
        hsh[name] = value
      }
      list.push(hsh)
    }
    return list
  end


end
