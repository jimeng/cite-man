require 'csl_processor'
require 'json'
require 'oauth/consumer'

class MendeleyItemController < ActionController::Base

  before_filter :load_source


  def index

    #debugger
    #Rails.backtrace_cleaner.remove_silencers!
    logger.info("MendeleyItemController.index")

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

     @styled = CslProcessor.formatCitations('mla-url', @items)

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
