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
      :authorize_path     => "/oauth/authorize/",
      :callback 		  => callbackUrl
    })
    request_token = consumer.get_request_token
    Rails.logger.info(request_token)
    authorize_url = request_token.authorize_url
    Rails.logger.info(authorize_url)
    return request_token
  end

  def MendeleyItem.getAccessToken(request_token)
  	access_token = request_token.get_access_token()
  	return access_token
  end


end