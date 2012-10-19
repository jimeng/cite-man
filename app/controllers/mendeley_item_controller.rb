require 'csl_processor'
require 'json'
require 'oauth/consumer'

class MendeleyItemController < ActionController::Base

  before_filter :load_source


  def index

    #debugger
    #Rails.backtrace_cleaner.remove_silencers!
    logger.info("MendeleyItemController.index")

    if session[:access_token]
      render_citations
    elsif session[:request_token]
      @request_token = session[:request_token]
      @access_token = MendeleyItem.getAccessToken(@request_token)
      session[:access_token] = @access_token
      cookies[:mendeley_access_token] = 'true'
      render_citations
    else
      @request_token = MendeleyItem.getRequestToken(source_mendeley_item_index_path(@source)) 
      session[:request_token] = @request_token
      r_token = {}
      r_token[:request_token] = @request_token

      r_token[:authorize_url] = @request_token.authorize_url

      Rails.logger.info(r_token)
      respond_to do |format|
        format.json { render :json => r_token }
      end
    end
  end

  def render_citations
      collection_path = "oapi/library?consumer_key=#{@source.code01}"

      begin
        # debugger
        @items = MendeleyItem.find( :all, :from => collection_path ) || []
      rescue => e
        Rails.logger.info(e.message)
      end

      #Rails.logger.info(@items)
      # debugger

       #Rails.logger.info('===============================')

       @styled = CslProcessor.formatCitations('mla-notes', @items)

      #logger.info(@styled)
      #Rails.logger.info('===============================')

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @items }
      end

  end

  def authenticate
    logger.info("MendeleyItemController.authenticate")
    raise request.env("omniauth.auth").to_yaml
  end

private

  def load_source 
    logger.info('loading source in MendeleyItemController')
    @source = Source.find(params[:source_id])
    logger.info('loaded source in MendeleyItemController')

  end

end
