require 'json'
require 'date'

class MendeleyItem < ActiveResource::Base

  #self.site = "http://127.0.0.1:1337/"
  self.site = "http://api.mendeley.com"
  #self.element_name = "items"

  def MendeleyItem.getRequestToken(callbackUrl)
    consumer = OAuth::Consumer.new( "97f4e0896ab36d7b55e5f1a2b81e396c05010616b","034392514f666e3f236973d935757097", {
      :site				  => self.site,
      :scheme             => :header,
      :http_method        => :get,
      :request_token_path => "/oauth/request_token/",
      :access_token_path  => "/oauth/access_token/",
      :authorize_path     => "/oauth/authorize/"
    })
    begin
      request_token = consumer.get_request_token({:oauth_callback => callbackUrl})
      #Rails.logger.info(request_token)
      authorize_url = request_token.authorize_url
      #Rails.logger.info(authorize_url)
    rescue => e
      Rails.logger.warn(e.message)
      #Rails.logger.warn(e.class)
    end
    return request_token
  end

  def MendeleyItem.getAccessToken(request_token, oauth_verifier, oauth_token)
  	access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier, :oauth_token => oauth_token)
  	return access_token
  end

  def MendeleyItem.getCitations(access_token, page = 0, items = 20)
    Rails.logger.info("MendeleyItem.getCitations(#{access_token}, #{page}, #{items})")
    response = access_token.get("/oapi/library/?page=#{page}&items=#{items}")
    #Rails.logger.info(response)
    if(Net::HTTPSuccess === response) 
      hash = JSON.parse( response.body )
      #Rails.logger.info(hash)
      document_ids = hash['document_ids']
      #Rails.logger.info(document_ids)
      list = []
      document_ids.each { |id| 
        # /oapi/library/documents/123456789/
        r = access_token.get("/oapi/library/documents/#{id}/")
        if(Net::HTTPSuccess === r) 
          cite = JSON.parse(r.body)
          list.push cite
       end
      }
      #Rails.logger.info( list )
      #debugger
    else
      list = []
      #debugger
    end
    return list
  end

  def MendeleyItem.cslFormat(citations = [])
    formatted_citations = []
    Rails.logger.info('================ MendeleyItem.cslFormat() ===================')
    citations.each { |citation|
      formatted_citation = {}
      issued = []
      citation.each{ |name,value|
        case name
        when 'id'
          formatted_citation[:id] = value.to_s
        when 'type'
          formatted_citation[:type] = MendeleyItem.processType(value)
        when 'authors'
          formatted_citation[:author] = MendeleyItem.processNameList(value)
         when 'editors'
          formatted_citation[:editor] = MendeleyItem.processNameList(value)
        when "seriesEditor"
          formatted_citation["collection-editor"] = MendeleyItem.processNameList(value)
        when "keywords"
          formatted_citation["keywords"] = MendeleyItem.processStringList(value)
        when 'title'
          formatted_citation[:title] = value
        when "shortTitle"
          formatted_citation["title-short"] = value
          formatted_citation[:shortTitle] = value
        when 'abstract'
          formatted_citation[:abstract] = value
        when 'language'
          formatted_citation[:language] = value
        when 'doi'
          formatted_citation[:DOI] = value
        when 'edition'
          formatted_citation[:edition] = value.to_s
        when "volume"
          formatted_citation[:volume] = value.to_s
        when "issue"
          formatted_citation[:issue] = value.to_s
        when "revisionNumber"
          formatted_citation[:version] = value.to_s
        when "chapter"
          formatted_citation["chapter-number"] = value.to_s
          formatted_citation[:section] = value.to_s
        when "dateAccessed"
          formatted_citation[:accessed] = MendeleyItem.processDate(value)
        when "website"
          formatted_citation[:URL] = value
        when "pages"
          formatted_citation[:page] = value.to_s
        when "length"
          formatted_citation["number-of-pages"] = value.to_s
        when "issn"
          formatted_citation[:ISSN] = value.to_s
        when "isbn"
          formatted_citation[:ISBN] = value.to_s
        when "pmid"
          formatted_citation[:PMID] = value.to_s
        when "pmcid"
          formatted_citation[:PMCID] = value.to_s
        when "publication"
          formatted_citation["container-title"] = value.to_s
        when "published_in"
          formatted_citation["container-title"] = value.to_s
        when "publisher"
          formatted_citation[:publisher] = value.to_s
        when "city"
          formatted_citation["publisher-place"] = value.to_s
        when "year"
          issued[0] = value.to_s
        when "month"
          issued[1] = value.to_s
        when "day"
          issued[2] = value.to_s
        else
          Rails.logger.info("#{name} == #{value}")
        end
      }
      formatted_citation[:issued] = { "date-parts" => issued }
      formatted_citations.push(formatted_citation)
      Rails.logger.info(formatted_citation.to_json.to_s)
      Rails.logger.info('---------------- MendeleyItem.cslFormat() -------------------')

    }
    rv = {}
    rv[:items] = formatted_citations
    #rv[:citationItems] = formatted_citations
    #Rails.logger.info(rv)
    Rails.logger.info('================ MendeleyItem.cslFormat() ===================')
    return rv
  end

  def MendeleyItem.processNameList(raw_list = [])
    formatted_list = []
    raw_list.each { |author| 
      formatted_author = {}
      formatted_author[:family] = author["surname"]
      formatted_author[:given] = author["forename"]
      formatted_list.push( formatted_author )
    }
    return formatted_list
  end 

  def MendeleyItem.processStringList(raw_list = [])
    return raw_list
  end

  def MendeleyItem.processDate(raw_date) 
    rv = {}
    begin
      date = Date.strptime(raw_date, '%d/%m/%y')
      dateparts = []
      dateparts.push(date.year.to_s)
      dateparts.push(date.mon.to_s)
      dateparts.push(date.mday.to_s)
      rv['date-parts'] = dateparts
    rescue => e
      rv[:raw] = raw_date.to_s
      rv[:literal] = raw_date.to_s
    end
  end

  def MendeleyItem.processType(type) 
    case type
    when "Bill"
      "bill"
    when "Book"
      "book"
    when "Book Section"
      "chapter"
    when "Case"
      "legal_case"
    when "Computer Program"
      ""
    when "Conference Proceedings"
      "paper-conference"
    when "Encyclopedia Article"
      "entry-encyclopedia"
    when "Film"
      "motion_picture"
    when "Generic"
      ""
    when "Hearing"
      ""
    when "Journal Article"
      "article-journal"
    when "Magazine Article"
      "article-magazine"
    when "Newspaper Article"
      "article-newspaper"
    when "Patent"
      "patent"
    when "Report"
      "report"
    when "Statute"
      "legislation"
    when "Television Broadcast"
      "broadcast"
    when "Thesis"
      "thesis"
    when "Web Page"
      "webpage"
    when "Working Paper"
      ""
    end
  end

end