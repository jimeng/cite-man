require 'json'

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
    request_token = consumer.get_request_token({:oauth_callback => callbackUrl})
    Rails.logger.info(request_token)
    authorize_url = request_token.authorize_url
    Rails.logger.info(authorize_url)
    return request_token
  end

  def MendeleyItem.getAccessToken(request_token, oauth_verifier, oauth_token)
  	access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier, :oauth_token => oauth_token)
  	return access_token
  end

  def MendeleyItem.getCitations(access_token, page = 0, items = 20)
    Rails.logger.info('MendeleyItem.getCitations(#{access_token}, #{page}, #{items})')
    response = access_token.get("/oapi/library/?page=#{page}&items=#{items}")
    Rails.logger.info(response)
    if(Net::HTTPSuccess === response) 
      hash = JSON.parse( response.body )
      Rails.logger.info(hash)
      document_ids = hash['document_ids']
      Rails.logger.info(document_ids)
      list = []
      document_ids.each { |id| 
        # /oapi/library/documents/123456789/
        r = access_token.get("/oapi/library/documents/#{id}/")
        if(Net::HTTPSuccess === r) 
          cite = JSON.parse(r.body)
         list.push cite
       end
      }
      Rails.logger.info( list )
      #debugger
    else
      list = []
      #debugger
    end
    return list
  end

  def MendeleyItem.cslFormat(citations = [])
    formatted_citations = []
    citation.each { |citation|
      citation.each{ |name,value|
        formatted_citation = {}
        case name
        when 'type'
          formatted_citation[:type] = MendeleyItem.processType(value)
        when 'authors'
          formatted_citation[:author] = MendeleyItem.processAuthors(value)
        when 'id'
          formatted_citation[:id] = value.to_s
        when 'abstract'
          formatted_citation[:abstract] = value.to_s
        when 'language'
          formatted_citation[:language] = value
        when 'edition'
          formatted_citation[:edition] = value
        else
          Rails.logger.info("#{name} == #{value}")
        end
      }
    }
    return formatted_citations
  end

  def MendeleyItem.processAuthors(raw_list = [])
    formatted_list = []
    raw_list.each { |author| 
      formatted_author = {}
      formatted_author[:family] = author[:surname]
      formatted_author[:given] = author[:forename]
      formatted_list.push( formatted_author )
    }
    return formatted_list
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