class CslProcessor

  def CslProcessor.formatCitations(style_id, citations=[], as_table=true, with_checkboxes=true, include_hidden_json=true)
    #Rails.logger.info(citations.to_json.to_s)
    #Rails.logger.info(citations)
    url = "http://127.0.0.1:8085"

    uri = URI.parse(url)
    uri.query = 'responseformat=json&style=' + style_id

    items = {}

    if(citations.is_a?(Array))
      citations.each { |citation|
        Rails.logger.info(citation.to_json.to_s)
        # debugger
        citation_id = citation[:id]
        if(citation_id.nil? || citation_id == '')
          citation_id = citation['id']
        end
        items[citation_id] = citation
      }
      #Rails.logger.info(items.class)
      #Rails.logger.info(items.inspect)

      json = items.to_json
      #Rails.logger.info(json.to_s)
      jsonStr = "{ \"items\" : " + json.to_s + " }"
    elsif citations.is_a?(String)
      jsonStr = citations
      items = JSON.parse(citations)["items"]
    end
   
    Rails.logger.info(jsonStr.class)
    Rails.logger.info(items.class)
 
    request = Net::HTTP::Post.new(uri.request_uri)

    request.body = jsonStr

    #Rails.logger.info('1 ===============================================')
    #Rails.logger.info(request.body)
    #Rails.logger.info('2 ===============================================')

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    #Rails.logger.info(response)
    #Rails.logger.info('3 ===============================================')
    #Rails.logger.info(response.body)
    #Rails.logger.info('4 ===============================================')
    # debugger

    begin
      index = 0
      respJson = JSON.parse(response.body)
      html = respJson["bibliography"][0]['bibstart']
      html += "<table>\n<thead><tr>" if as_table
      html += "<th id='check'></th>" if as_table && with_checkboxes
      html += "<th id='cite'></th></thead>\n<tbody>" if as_table
      div_list = respJson["bibliography"][1]
      cite_list = respJson["bibliography"][0]['entry_ids']
      #Rails.logger.info(json.to_s)
      #Rails.logger.info('----')
      div_list.each {|div|
        html += "<tr>" if as_table
        citeId = cite_list[index][0].to_s
        Rails.logger.info(citeId)
        Rails.logger.info(items.class)
        Rails.logger.info(items.class)
        #Rails.logger.info(json.class)
        Rails.logger.info('----')
        if(include_hidden_json) 
          ri = div.rindex('</div>')
          if(ri && ri > 0) 
            div = div.insert(ri, '\n<script type="text/javascript">citations_manager.renderred_citations["' + citeId +'"] = ' + items[citeId].to_json.to_s + ';</script>\n')
          end
        end
        html += "<td class='citation_checkbox'><input type='checkbox' value='" + citeId + "'/></td>" if as_table && with_checkboxes
        html += "<td>\n" if as_table
        html += div + "\n"
        html += "</td>\n" if as_table
        index = index + 1
      }
      html += "</tbody>\n</table>\n" if as_table
      html += respJson["bibliography"][0]['bibend'] 
    rescue => e
      Rails.logger.info(e.message)
      #Rails.logger.info(e.backtrace.join("\n"))
    end
     # debugger
    return html

  end

  def CslProcessor.getStyles(filter)
    list = Array.new
    url = "http://127.0.0.1:8085"

    uri = URI.parse(url)
    uri.path = '/styles/'
    uri.query = 'filter=' + filter

    request = Net::HTTP::Get.new uri.request_uri

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request request 
    end

    jsonObj = JSON.parse(response.read_body())
    jsonObj['cslShortNames'].each{|name,value|
      list.push(name)
    }
    #jsonObj['cslDependentShortNames'].each{|name,value|
    #  list.push(name)
    #}

    list.sort!

    return list
  end

end