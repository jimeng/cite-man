require 'json'
require 'date'

class MendeleyItem < ActiveResource::Base

  #self.site = "http://127.0.0.1:1337/"
  self.site = "http://api.mendeley.com"
  #self.element_name = "items"

  def MendeleyItem.getRequestToken(callbackUrl)

    key = ConfigValue.where(:source_type => 'mendeley', :name => 'key').first[:value]
    secret = ConfigValue.where(:source_type => 'mendeley', :name => 'secret').first[:value]

    consumer = OAuth::Consumer.new( key,secret, {
      :site				  => self.site,
      :scheme             => :header,
      :http_method        => :get,
      :request_token_path => "/oauth/request_token/",
      :access_token_path  => "/oauth/access_token/",
      :authorize_path     => "/oauth/authorize/"
    })
    begin
      request_token = consumer.get_request_token({:oauth_callback => callbackUrl})
      ##Rails.logger.info(request_token)
      authorize_url = request_token.authorize_url
      ##Rails.logger.info(authorize_url)
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
    #Rails.logger.info("MendeleyItem.getCitations(#{access_token}, #{page}, #{items})")
    response = access_token.get("/oapi/library/?page=#{page}&items=#{items}")
    ##Rails.logger.info(response)
    if(Net::HTTPSuccess === response) 
      hash = JSON.parse( response.body )
      ##Rails.logger.info(hash)
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
      ##Rails.logger.info( list )
      #debugger
    else
      list = []
      #debugger
    end
    return list
  end

  def MendeleyItem.cslFormat(citations = [])
    formatted_citations = []
    #Rails.logger.info('================ MendeleyItem.cslFormat() ===================')
    citations.each { |citation|
      formatted_citation = {}
      issued = []
      ctype = citation[:type]
      if(ctype.nil?) 
        #Rails.logger.info('ctype nil 1')
        ctype = citation['type']
      end
      if(ctype.nil?) 
        #Rails.logger.info('ctype nil 2')
        ctype = citation.type
      end
      #Rails.logger.info(ctype)
      citation.each{ |name,value|
        case name.downcase
        when 'abstract'
          formatted_citation[:abstract] = value.to_json
        when 'authors'
          formatted_citation[:author] = MendeleyItem.processNameList(value)
        when 'book'
          formatted_citation['container-title'] = value.to_json
        when 'chapter'
          formatted_citation['chapter-number'] = value.to_json
        when 'city'
          formatted_citation['publisher-place'] = value.to_json
        when 'code pages'
          formatted_citation[:page] = value.to_json
        when 'date accessed', 'dateaccessed'
          formatted_citation[:accessed] = MendeleyItem.processDate(value)
        when 'distributor'
          formatted_citation[:publisher] = value.to_json
        when 'doi'
          formatted_citation[:DOI] = value.to_json
        when 'edition'
          formatted_citation[:edition] = value.to_json
         when 'editors'
          formatted_citation[:editor] = MendeleyItem.processNameList(value)
        when 'encyclopedia'
          formatted_citation['container-title'] = value.to_json
        when 'genre'
          formatted_citation[:genre] = value.to_json
        when 'id'
          formatted_citation[:id] = value.to_json
        when 'identifiers'
          if value.nil?

          elsif value.is_a? Array
            value.each{ |n,v| 
              formatted_citation[n] = v.to_json
            }
          end
        when 'isbn'
          formatted_citation[:ISBN] = value.to_json
        when 'issn'
          formatted_citation[:ISSN] = value.to_json
        when "issue"
          formatted_citation[:issue] = value.to_json
        when 'issuer'
          formatted_citation[:publisher] = value.to_json
        when 'journal'
          formatted_citation['container-title'] = value.to_json
        when "keywords"
          formatted_citation['keyword'] = MendeleyItem.processStringList(value)
        when 'language'
          formatted_citation[:language] = value.to_json
        when 'legislative body'
          formatted_citation[:publisher] = value.to_json
        when "length"
          formatted_citation['number-of-pages'] = value.to_json
        when 'note'
          formatted_citation[:note] = value.to_json
        when 'number'
          formatted_citation[:number] = value.to_json
        when 'pages'
          formatted_citation[:page] = value.to_json
        when "pmid"
          formatted_citation[:PMID] = value.to_json
        when "pmcid"
          formatted_citation[:PMCID] = value.to_json
        when 'proc. title'
          formatted_citation['container-title'] = value.to_json
        when 'publication'
          formatted_citation['container-title'] = value.to_json
        when "published_in"
          formatted_citation['container-title'] = value.to_json
        when 'publisher'
          formatted_citation[:publisher] = value.to_json
        when 'revision number'
          formatted_citation[:number] = value.to_json
        when "serieseditor", "series editor"
          formatted_citation['collection-editor'] = MendeleyItem.processNameList(value)
        when 'series title'
          formatted_citation['container-title'] = value.to_json
        when 'series volume'
          formatted_citation[:volume] = value.to_json
        when 'short title', 'short_title'
          formatted_citation[:shortTitle] = value.to_json
          formatted_citation['title-short'] = value.to_json
        when 'source'
          if(ctype == 'Patent')
            formatted_citation['container-title'] = value.to_json
          else
            formatted_citation[:publisher] = value.to_json
          end
        when 'statute number'
          formatted_citation[:number] = value.to_json
        when 'title'
          formatted_citation[:title] = value.to_json
        when 'type'
          formatted_citation[:type] = MendeleyItem.processType(value)
        when 'version'
          formatted_citation[:number] = value.to_json
        when 'volume'
          formatted_citation[:volume] = value.to_json
        when "website"
          formatted_citation[:URL] = value.to_json
        when 'url'
          formatted_citation[:URL] = value.to_json
        when "year"
          issued[0] = value.to_json
        when "month"
          issued[1] = value.to_json
        when "day"
          issued[2] = value.to_json
        else
          Rails.logger.info("#{name} == #{value}")
        end
      }
      formatted_citation[:issued] = { "date-parts" => issued }
      formatted_citations.push(formatted_citation)
      #Rails.logger.info(formatted_citation.to_json.to_s)
      #Rails.logger.info('---------------- MendeleyItem.cslFormat() -------------------')

    }
    rv = {}
    rv[:items] = formatted_citations
    #rv[:citationItems] = formatted_citations
    ##Rails.logger.info(rv)
    #Rails.logger.info('================ MendeleyItem.cslFormat() ===================')
    return rv
  end

  def MendeleyItem.processNameList(raw_list = [])
    formatted_list = []
    raw_list.each { |author| 
      formatted_author = {}
      formatted_author[:family] = author["surname"].to_json
      formatted_author[:given] = author["forename"].to_json
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
      dateparts.push(date.year.to_json)
      dateparts.push(date.mon.to_json)
      dateparts.push(date.mday.to_json)
      rv['date-parts'] = dateparts
    rescue => e
      rv[:raw] = raw_date.to_json
      rv[:literal] = raw_date.to_json
    end
  end

  def MendeleyItem.processType(type) 
    case type.downcase
      when 'bill'
        'bill'
      when 'book'
        'book'
      when 'book section'
        'chapter'
      when 'case'
        'article'
      when 'computer program'
        'article'
      when 'conference proceedings'
        'paper-conference'
      when 'encyclopedia article'
        'entry-encyclopedia'
      when 'film'
        'motion_picture'
      when 'generic'
        'article'
      when 'hearing'
        'speech'
      when 'journal article'
        'article-journal'
      when 'magazine article'
        'article-magazine'
      when 'newspaper article'
        'article-newspaper'
      when 'patent'
        'patent'
      when 'report'
        'report'
      when 'statute'
        'legislation'
      when 'television broadcast'
        'broadcast'
      when 'thesis'
        'thesis'
      when 'web page'
        'webpage'
      when 'working paper'
          'article'
    end
  end

end