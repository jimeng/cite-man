class FavoriteItemController < ActionController::Base

  before_filter :load_person
  #before_filter :load_source


  def index

    #debugger
    #Rails.backtrace_cleaner.remove_silencers!
    logger.info("FavoriteItemController.index")

    render_citations
  end

private

  def load_person
    logger.info("loading person in FavoriteItemController")
    if(params[:person_id]) 
      @person = Person.find(params[:person_id])
      logger.info("loaded person in FavoriteItemController using params #{@person.inspect}")
  	elsif(session[:person_id])
      @person = Person.find(session[:person_id])
      logger.info("loaded person in FavoriteItemController using session #{@person.inspect}")
  	end
  end

  def render_citations
    logger.info('FavoriteItemController.render_citations')
    
    begin
      @items = FavoriteItem.getCitations({:uniqname => @person[:user_id]}) 
      logger.info('@items.length == ' + @items.length.to_s)

      @formatted = FavoriteItem.cslFormat(@items)
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
        #logger.info e.backtrace.join("\n")
        logger.warn(e.class)
        logger.warn(e.message)
        handle_error(e)
      end
    end
  end

  def handle_error(e)
    rv = {}
    #rv[:request_token] = nil
    #rv[:authorize_url] = nil
    case e
    when Net::HTTPServiceUnavailable
      rv[:error] = "Favorites is up, but something went wrong, please try again later."
    when ActiveResource::BadRequest
      rv[:error] = "The request was invalid. #{e.message}."
    when ActiveResource::UnauthorizedAccess
      rv[:error] = "Authentication credentials were missing or incorrect."
    when ActiveResource::ForbiddenAccess
      rv[:error] = "The request is understood, but it has been refused. #{e.message}."
  	when ActiveResource::ResourceNotFound
       rv[:error] = "The request is understood, but it has been refused. #{e.message}."
    when ActiveResource::ResourceConflict
      rv[:error] = "409 error."
    else
      rv[:error] = "Unknown error.  Please try again later"
    end
    respond_to do |format|
      format.json {render :json => rv}
    end
  end


  def permission_denied
    render :file => "public/401", :status => :unauthorized, :formats => [:html]
  end

end