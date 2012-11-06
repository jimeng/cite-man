class ConfigValuesController < ApplicationController
  # GET /config_values
  # GET /config_values.json
  def index
    @config_values = ConfigValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @config_values }
    end
  end

  # GET /config_values/1
  # GET /config_values/1.json
  def show
    @config_value = ConfigValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @config_value }
    end
  end

  # GET /config_values/new
  # GET /config_values/new.json
  def new
    @config_value = ConfigValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @config_value }
    end
  end

  # GET /config_values/1/edit
  def edit
    @config_value = ConfigValue.find(params[:id])
  end

  # POST /config_values
  # POST /config_values.json
  def create
    @config_value = ConfigValue.new(params[:config_value])

    respond_to do |format|
      if @config_value.save
        format.html { redirect_to @config_value, :notice => 'Config value was successfully created.' }
        format.json { render :json => @config_value, :status => :created, :location => @config_value }
      else
        format.html { render :action => "new" }
        format.json { render :json => @config_value.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /config_values/1
  # PUT /config_values/1.json
  def update
    @config_value = ConfigValue.find(params[:id])

    respond_to do |format|
      if @config_value.update_attributes(params[:config_value])
        format.html { redirect_to @config_value, :notice => 'Config value was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @config_value.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /config_values/1
  # DELETE /config_values/1.json
  def destroy
    @config_value = ConfigValue.find(params[:id])
    @config_value.destroy

    respond_to do |format|
      format.html { redirect_to config_values_url }
      format.json { head :no_content }
    end
  end
end
