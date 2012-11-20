require 'openssl'
require 'base64'
require 'favorites_json_format'

class FavoriteItem < ActiveResource::Base

=begin
  module JsonWrapper 
    extend self

    def extension
      "json"
    end

    def mime_type
      "application/json"
    end

    def encode(hash, options = nil)
      ActiveSupport::JSON.encode(hash, options)
    end


    def decode(json)
      Rails.logger.info(json.to_s)
      ActiveSupport::JSON.decode(json)
    end
  end

  FavoriteItem.format = JsonWrapper

=end

  #self.site = "http://127.0.0.1:1337/"
  self.site = "http://www.lib.umich.edu"
  self.element_name = "item"

  def FavoriteItem.getCitations(options={})
    id = ConfigValue.where(:source_type => 'favorite', :name => 'id').first[:value]
    secret = ConfigValue.where(:source_type => 'favorite', :name => 'secret').first[:value]
    timestamp = Time.now.to_i
    uniqname = 'bertrama'
    #uniqname = options[:uniqname]

    data = "id=#{id}\ntimestamp=#{timestamp}\nuniqname=#{uniqname}"

    Rails.logger.info("FavoriteItem.getCitations #{data}")

    begin
      hmacsha1 = OpenSSL::HMAC.digest('sha1', secret, data)
      Rails.logger.info("FavoriteItem.getCitations #{hmacsha1}")
      base64 = Base64.encode64(hmacsha1).chomp
      Rails.logger.info("FavoriteItem.getCitations #{base64}")
    rescue => e
      Rails.logger.warn('stop 1')
      Rails.logger.warn(e)
      Rails.logger.info(e.backtrace.join("\n"))
    end


    params = {}
    params[:id] = id
    params[:timestamp] = timestamp
    params[:uniqname] = uniqname
    params[:checksum] = base64

    FavoriteItem.format = ActiveResource::Formats::FavoritesJsonFormat

    begin 
      debugger
      items = FavoriteItem.find(:all, :from => '/favorites/api/list', :params => params)
      #Rails.logger.info(items.inspect)
    rescue => e
      Rails.logger.warn(e.class)
      Rails.logger.warn(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      raise e
    end

    items
  end


end

