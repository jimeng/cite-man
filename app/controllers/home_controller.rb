class HomeController < ApplicationController
  def index
    logger.info("HomeController.index")
    @person = Person.find_or_create_by_user_id(params[:lis_person_sourcedid], :full_name => params[:lis_person_name_full], :given_name => params[:lis_person_name_given], :family_name => params[:lis_person_name_family])
    logger.info( @person.instance_variables )
    
    #debugger
    session[:person_id] = @person[:id]
    session['oauth'] ||= {}

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
    @person = Person.find(params[:person_id])
    
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


end
