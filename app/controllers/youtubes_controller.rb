class YoutubesController < ApplicationController

  before_filter :authenticate_user!
  
  # GET /youtubes
  # GET /youtubes.json
  def index
    @youtubes = Youtube.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @youtubes }
    end
  end

  # GET /youtubes/1
  # GET /youtubes/1.json
  def show
    @youtube = Youtube.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @youtube }
    end
  end

  # GET /youtubes/new
  # GET /youtubes/new.json
  def new
    @youtube = Youtube.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @youtube }
    end
  end

  # GET /youtubes/1/edit
  def edit
    @youtube = Youtube.find(params[:id])
  end

  # POST /youtubes
  # POST /youtubes.json
  def create
    @youtube = Youtube.new(params[:youtube])

    respond_to do |format|
      if @youtube.save
        format.html { redirect_to @youtube, :notice => 'Youtube was successfully created.' }
        format.json { render :json => @youtube, :status => :created, :location => @youtube }
      else
        format.html { render :action => "new" }
        format.json { render :json => @youtube.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /youtubes/1
  # PUT /youtubes/1.json
  def update
    @youtube = Youtube.find(params[:id])

    respond_to do |format|
      if @youtube.update_attributes(params[:youtube])
        format.html { redirect_to @youtube, :notice => 'Youtube was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @youtube.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /youtubes/1
  # DELETE /youtubes/1.json
  def destroy
    @youtube = Youtube.find(params[:id])
    @youtube.destroy

    respond_to do |format|
      format.html { redirect_to youtubes_url }
      format.json { head :ok }
    end
  end

  def recommendations
    client = YouTubeIt::OAuthClient.new("primetime-dev.infinite-labs.net", "g4LLGFt7FTTXOCLz85fXFzu_", "TwistedL0g1c", "AI39si50pWc6_Dsthhh-Wd49dkeffX6HX8TWhztcx_zgaTusACAnIhzlHS7xWZRPuNXJfkrgqFJRUu1WL17WH11iKWMjYQzNxQ")
    client.authorize_from_access("access_token", "access_secret")
  end
end
