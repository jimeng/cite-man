require 'csl_processor'
require 'json'

class ZoteroItemController < ActionController::Base

  before_filter :load_source


  def index

    #debugger
    #Rails.backtrace_cleaner.remove_silencers!
    logger.info("ZoteroItemController.index")

    collection_path = "/users/#{@source.client_id}/items?format=atom&content=csljson&limit=99&key=#{@source.client_key}"

    begin
      # debugger
      @items = ZoteroItem.find( :all, :from => collection_path ) || []
    rescue => e
      Rails.logger.info(e.message)
    end

    #Rails.logger.info(@items)
    # debugger

     #Rails.logger.info('===============================')

    @formatted = ZoteroItem.cslFormat(@items)

    style = @source.default_style
    style = 'mla' if style.nil? 

    # @styled = CslProcessor.formatCitations('mla-url', 'html', @items)
    
    @styled = CslProcessor.formatCitations(style, @formatted[:items])

    #logger.info(@styled)
    #Rails.logger.info('===============================')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @styled }
      # format.json { render :json => @items }
    end
  end

private

  def load_source 
    @source = Source.find(params[:source_id])
  end

end