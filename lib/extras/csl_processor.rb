class CslProcessor

  def CslProcessor.formatCitations(style_id, citations={})

    url = "http://127.0.0.1:8085"

    uri = URI.parse(url)
    uri.query = 'responseformat=json&style=' + style_id

    items = {}
    citations.each { |citation|
      items[citation.attributes[:id]] = citation
    }
   
    json = items.to_json

    request = Net::HTTP::Post.new(uri.request_uri)

    request.body = "{ \"items\" : " + json.to_s + " }"

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    json = JSON.parse(response.body)
    html = json["bibliography"][0]['bibstart']
    json["bibliography"][1].each {|div|
      html += div + "\n"
    }
    html += json["bibliography"][0]['bibend'] 

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