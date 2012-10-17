class SourcesController < ActionController::Base

  before_filter :load_person

  # GET /sources
  # GET /sources.json
  def index
    @sources = @person.sources.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @sources }
    end
  end

  # GET /sources/1
  # GET /sources/1.json
  def show
    logger.info('SourcesController.show')
    @source = @person.sources.find(params[:id])
    logger.info(@source)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @source }
    end
  end

  # GET /sources/new
  # GET /sources/new.json
  def new
    @source = @person.sources.new

    session[:access_token] = nil
    session[:request_token] = nil

    @styles = CslProcessor.getStyles('all')
    @preferred_style = @person.preferred_style

    respond_to do |format|
      format.html { render :layout => false if request.xhr? } # new.html.erb
      format.json { render :json => @source }
    end
  end

  # GET /sources/1/edit
  def edit
    @source = @person.sources.find(params[:id])
    @styles = CslProcessor.getStyles('all')
    @preferred_style = @person.preferred_style
    render :layout => false if request.xhr? 
  end

  # POST /sources
  # POST /sources.json
  def create
    logger.info(params[:source])

    @source = @person.sources.new(params[:source])

    case 
    when @source[:provider] == 'mendeley' && isNull( @source[:code01] )
      logger.info("mendeley source created")
      auth_mendeley
    else
      render_sources
    end
  end

  # PUT /sources/1
  # PUT /sources/1.json
  def update
    logger.info(params[:id])
    logger.info(params[:source])

    @source = @person.sources.find(params[:id])

    respond_to do |format|
      if @source.update_attributes(params[:source])
        format.html { 
          @sources = @person.sources
          render :template => "home/_sources", :layout => false,  :notice => 'Source was successfully updated.'  
        }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.json
  def destroy
    @source = @person.sources.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { 
          @sources = @person.sources
          render :template => "home/_sources", :layout => false,  :notice => 'Source was successfully updated.'  
        }
      format.json { head :no_content }
    end
  end

  def items
    @source = Source.find(params[:id])

    case @source.source_type
    when 'zotero'
      @items = [ { :title => 'Item 1', :author => 'Author, First', :date => '2011' }, { :title => 'Item 2', :author => 'Author, Second', :date => '2012' } ]
    else
      @items = []
    end

    logger.info(@items)

    respond_to do |format|
      format.html { render :layout => false } # items.html.erb
      format.json { render :json => @items }
    end

  end



  private 
  
    def load_person 
      if(person_id = params[:person_id])
        @person = Person.find(person_id)
      end
    end

    def auth_mendeley
      logger.info("auth_mendeley")
      logger.info(@source)
      if session[:access_token]
        logger.info("has access_token :: has request_token")
      elsif session[:request_token]
        logger.info("no access_token :: has request_token")
        @request_token = session[:request_token]
        #@request_token.verifier = @source[:code02]
        @access_token = @request_token.get_access_token(:oauth_verifier => @source[:code02])
        session[:access_token] = @access_token
        @source[:code01] = @access_token
        render_sources
      else
        logger.info("no access_token :: no request_token")
        @consumer=OAuth::Consumer.new( "97f4e0896ab36d7b55e5f1a2b81e396c05010616b","034392514f666e3f236973d935757097", {
          :site=>"http://api.mendeley.com",
          :scheme             => :header,
          :http_method        => :get,
          :request_token_path => "/oauth/request_token/",
          :access_token_path  => "/oauth/access_token/",
          :authorize_path     => "/oauth/authorize/"
        })
        @request_token = @consumer.get_request_token
        logger.info(@request_token)
        authorize_url = @request_token.authorize_url
        logger.info(authorize_url)
        session[:request_token] = @request_token

        respond_to do |format|
          format.all { render :json => { :authorize_url => authorize_url } }
        end

      end

    end

    def isNull (var1)
      var1 == nil || var1 == ''
    end

    def render_sources
      respond_to do |format|
        if @source.save
          format.html { 
            @sources = @person.sources
            render :template => "home/_sources", :layout => false, :notice => 'Source was successfully created.' 
          }
          format.json { render :json => @source, :status => :created, :location => @source }
        else
          format.html { render :action => "new" }
          format.json { render :json => @source.errors, :status => :unprocessable_entity }
        end
      end
    end
    
end
