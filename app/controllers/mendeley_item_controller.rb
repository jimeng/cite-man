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
      logger.info('MendeleyItemController.index with access_token:')
      #debugger
      logger.info(session[:access_token])
      render_citations
    else
      redirect_to mendeley_auth_url(@source) 
    end
  end

  def access
    logger.info('MendeleyItemController.access')
    @request_token = session[:request_token]
    oauth_verifier = params[:oauth_verifier]
    oauth_token = params[:oauth_token]

    @access_token = MendeleyItem.getAccessToken(@request_token, oauth_verifier, oauth_token)
    session[:access_token] = @access_token
    respond_to do |format|
      format.html
    end
  end

  def auth      
    logger.info('MendeleyItemController.auth')

    @request_token = MendeleyItem.getRequestToken(mendeley_access_url(@source)) 
    session[:request_token] = @request_token
    r_token = {}
    r_token[:request_token] = @request_token

    r_token[:authorize_url] = @request_token.authorize_url

    logger.info(r_token)
    respond_to do |format|
      format.json { render :json => r_token }
    end
  end



  def render_citations
    logger.info('MendeleyItemController.render_citations')
    
    @access_token = session[:access_token]
    logger.info(@access_token)
    begin
      @items = MendeleyItem.getCitations( @access_token, 0, 15 ) 
    rescue => e
      logger.info(e.message)
    end

    logger.info(@items)

    @formatted = MendeleyItem.cslFormat(@items)
    # debugger

    #Rails.logger.info('===============================')

    #@styled = @items
    @styled = CslProcessor.formatCitations('mla-notes', @formatted)

      #logger.info(@styled)
      #Rails.logger.info('===============================')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @items }
    end

  end

private

  def load_source 
    logger.info('loading source in MendeleyItemController')
    @source = Source.find(params[:source_id])
    logger.info('loaded source in MendeleyItemController')

  end

end
