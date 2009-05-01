class ShorturlsController < ApplicationController
  # GET /shorturls
  # GET /shorturls.xml
  def index
    @shorturls = Shorturl.all
    @url_avail = Shorturl.find_by_id(params[:id]) if params[:id]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shorturls }
    end
  end

  # GET /shorturls/1
  # GET /shorturls/1.xml
  def show
    @shorturl = Shorturl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shorturl }
    end
  end

  # GET /shorturls/new
  # GET /shorturls/new.xml
  def new
    @shorturl = Shorturl.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shorturl }
    end
  end

  # GET /shorturls/1/edit
  def edit
    @shorturl = Shorturl.find(params[:id])
  end
  
  def parse
    @shorturl = Shorturl.find_by_id(params[:identifier].base62_decode)
    if @shorturl.target_url.match(/^http:\/\//)
     redirect_to  @shorturl.target_url
    else
     redirect_to  "http://#{@shorturl.target_url}" 
    end
  end
  
  def make_short
    if !params[:u].blank?
      @shorturl = Shorturl.new(:target_url => CGI.unescape(params[:u]))
      if @shorturl.save
        flash[:notice] = 'Shorturl was successfully created.'
        redirect_to root_path(:u => @shorturl.target_url)
      else
        @url_avail = Shorturl.find_by_target_url(CGI.unescape(params[:u]))
        flash[:notice] = 'URL is already shortened'
        redirect_to root_path(:u => @url_avail.target_url)
      end
    else
      flash[:notice] = "You must provide a url to shorten"
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @shorturl }
      end
    end

  end

  # POST /shorturls
  # POST /shorturls.xml
  def create
    @shorturl = Shorturl.new(params[:shorturl])
      respond_to do |format|
        if @shorturl.save
          flash[:notice] = 'Shorturl was successfully created.'
          if params[:from_front]
            format.html { redirect_to(root_path(:u => @shorturl.target_url)) }
          else
            format.html { redirect_to(@shorturl) }
          end
          format.xml  { render :xml => @shorturl, :status => :created, :location => @shorturl }
        else
          if params[:from_front]
            format.html { redirect_to(root_path(:u => @shorturl.target_url)) }
          else
            format.html { redirect_to(@shorturl) }
          end
        end
      end
  end

  # PUT /shorturls/1
  # PUT /shorturls/1.xml
  def update
    @shorturl = Shorturl.find(params[:id])

    respond_to do |format|
      if @shorturl.update_attributes(params[:shorturl])
        
        if params[:from_front]
          flash[:notice] = 'Shorturl was already shortened'
          format.html { redirect_to(root_path(:u => @shorturl.target_url)) }
        else
          flash[:notice] = 'Shorturl was successfully updated.'
          format.html { redirect_to(@shorturl) }
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shorturl.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shorturls/1
  # DELETE /shorturls/1.xml
  def destroy
    @shorturl = Shorturl.find(params[:id])
    @shorturl.destroy

    respond_to do |format|
      format.html { redirect_to(shorturls_url) }
      format.xml  { head :ok }
    end
  end
end
