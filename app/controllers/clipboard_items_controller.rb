class ClipboardItemsController < ApplicationController

  before_filter :load_person


  # GET /clipboard_items
  # GET /clipboard_items.json
  def index
    @clipboard_items = ClipboardItem.all

    jsonStr = "{ \"items\" : {"
    first = true
    @clipboard_items.each { |item|
      jsonStr += ', ' unless first
      cite = item.citation.sub("\n\r"," ").sub("\r\n"," ").sub("\n"," ").sub("\r"," ").chomp
      logger.info("----------------")
      logger.info(cite)
      jsonStr += "\"#{item.citation_id}\" : #{cite}" 
      first = false
    } 
    jsonStr += "} }"

    logger.info('--------------------------------------------')
    logger.info(jsonStr)
    logger.info('--------------------------------------------')
    style_id = @person.preferred_style

    @citation_table = CslProcessor.formatCitations(style_id, jsonStr)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @clipboard_items }
    end
  end

  # GET /clipboard_items/1
  # GET /clipboard_items/1.json
  def show
    @clipboard_item = ClipboardItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @clipboard_item }
    end
  end

  # GET /clipboard_items/new
  # GET /clipboard_items/new.json
  def new
    @clipboard_item = ClipboardItem.new

    respond_to do |format|
      #format.html # new.html.erb
      format.json { render :json => @clipboard_item }
    end
  end

  # GET /clipboard_items/1/edit
  def edit
    @clipboard_item = ClipboardItem.find(params[:id])
  end

  # POST /clipboard_items
  # POST /clipboard_items.json
  def create
    @clipboard_item = ClipboardItem.new(:citation => params[:citation], :citation_id => params[:citation_id], :person_id => params[:person_id])

    respond_to do |format|
      if @clipboard_item.save
        format.html { redirect_to @clipboard_item, :notice => 'Clipboard item was successfully created.' }
        format.json { render :json => @clipboard_item, :status => :created, :location => @clipboard_item }
      else
        format.html { render :action => "new" }
        format.json { render :json => @clipboard_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clipboard_items/1
  # PUT /clipboard_items/1.json
  def update
    @clipboard_item = ClipboardItem.find(params[:id])

    respond_to do |format|
      if @clipboard_item.update_attributes(params[:clipboard_item])
        format.html { redirect_to @clipboard_item, :notice => 'Clipboard item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @clipboard_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clipboard_items/1
  # DELETE /clipboard_items/1.json
  def destroy
    @clipboard_item = ClipboardItem.find(params[:id])
    @clipboard_item.destroy

    respond_to do |format|
      format.html { redirect_to clipboard_items_url }
      format.json { head :no_content }
    end
  end

  private 
  
    def load_person 
      if(person_id = params[:person_id])
        @person = Person.find(person_id)
      end
    end


end
