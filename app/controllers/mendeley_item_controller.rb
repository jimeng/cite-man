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
      #logger.info(session[:access_token])
      render_citations
    else
      permission_denied
    end
  end

  def access
    logger.info('MendeleyItemController.access')
    begin
      @request_token = session[:request_token]
      oauth_verifier = params[:oauth_verifier]
      oauth_token = params[:oauth_token]

      @access_token = MendeleyItem.getAccessToken(@request_token, oauth_verifier, oauth_token)
      session[:access_token] = @access_token
      session.delete(:request_token)
 
      respond_to do |format|
        format.html
      end
    
    rescue => e
      handle_error(e)
    end 
  end

  def auth      
    logger.info('MendeleyItemController.auth')

    begin
      @request_token = MendeleyItem.getRequestToken(mendeley_access_url(@source)) 
      session[:request_token] = @request_token
      r_token = {}
      r_token[:authorize_url] = @request_token.authorize_url

      #logger.info(r_token)
      respond_to do |format|
        format.json { render :json => r_token }
      end
    rescue => e
      handle_error(e)
    end

  end

  def handle_error(e)
    rv = {}
    #rv[:request_token] = nil
    #rv[:authorize_url] = nil
    case e
    when Net::HTTPServiceUnavailable
      rv[:error] = "Mendeley is up, but something went wrong, please try again later."
    when Net::HTTPBadRequest
      rv[:error] = "The request was invalid. #{e.message}."
    when Net::HTTPUnauthorized
      rv[:error] = "Authentication credentials were missing or incorrect."
    when Net::HTTPForbidden
      rv[:error] = "The request is understood, but it has been refused. #{e.message}."
    when Net::HTTPNotFound
      rv[:error] = "The URI requested is invalid or the resource requested doesn't exist."
    else
      rv[:error] = "Unknown error.  Please try again later"
    end
    respond_to do |format|
      format.json {render :json => rv}
    end
  end

  def render_citations
    logger.info('MendeleyItemController.render_citations')
    
    @access_token = session[:access_token]
    #logger.info(@access_token)
    begin
      @items = MendeleyItem.getCitations( @access_token, 0, 100 ) 
      logger.info('@items.length == ' + @items.length.to_s)

      @formatted = MendeleyItem.cslFormat(@items)
      #debugger

      #logger.info('@formatted.length == ' + @formatted[:items].length.to_s)
      #Rails.logger.info('===============================')

      style = @source.default_style
      style = 'mla' if style.nil? 

      #@styled = @items
      @styled = CslProcessor.formatCitations(style, @formatted[:items])

      #logger.info('@styled.length == ' + @styled[:bibliography].length.to_s)
        #logger.info(@styled)
        #Rails.logger.info('===============================')

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @items }
      end
    rescue => e
      if e.is_a? OAuth::Unauthorized
        session.delete(:access_token)
        permission_denied
      else
        logger.info('rescuing something')
        logger.info e.backtrace.join("\n")
        logger.warn(e.message)
        handle_error(e)
      end
    end
  end

private

  def load_source 
    logger.info("loading source in MendeleyItemController #{params[:source_id]}")
    @source = Source.find(params[:source_id])
    logger.info("loaded source in MendeleyItemController #{@source.inspect}")

  end

  def permission_denied
    render :file => "public/401", :status => :unauthorized, :formats => [:html]
  end

end
