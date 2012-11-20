class HomeController < ApplicationController

  before_filter :load_identity

  def index
    logger.info("HomeController.index")
    #debugger
    logger.info( @person.instance_variables )
    @clipboard_item = ClipboardItem.new
    
    #debugger
    @sources = @person.sources

    logger.info(@sources)
    @sources.each do |source|
      logger.info('-------------------')
      logger.info(source.id)
      logger.info(source.name)
    end

    logger.info('-------------------')
    
    respond_to do |format|
      format.html
      format.json { render :json => @person } 
    end    
  end

  def sources
    logger.info("HomeController.sources")
   
    @sources = @person.sources
    # @sources.each do |source|
    #   logger.info(source.name)
    # end
    
    respond_to do |format|
      format.html { render :partial => "sources" }
      format.json { render :json => @sources } 
    end   
  end

  def citations
    logger.info("HomeController.citations")
    @person = Person.find(params[:person_id])
    @source = @person.sources
  end

private

  def load_identity 
    logger.info("loading person in HomeController")

    if(session[:person_id]) 
      @person = Person.find(session[:person_id])

    else
      @person = Person.find_or_create_by_user_id(params[:lis_person_sourcedid], :full_name => params[:lis_person_name_full], :given_name => params[:lis_person_name_given], :family_name => params[:lis_person_name_family])
      session[:person_id] = @person[:id] 
      
      if(params[:roles]) 
        params[:roles].split(',').each do |role|
          if('Administrator' == role)
            session[:is_admin] = true
          end
        end
      end
    end

    @is_admin = session[:is_admin]

    logger.info("loaded person in MendeleyItemController #{@person.inspect} #{@is_admin}")

  end


end
