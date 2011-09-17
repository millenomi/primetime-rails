require 'gdata'
class YoutubesController < ApplicationController
  
  # GET /youtubes
  # GET /youtubes.json
  def index
    redirect_to '/youtubes/login' unless session[:token]
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
    client = GData::Client::YouTube.new
    client.authsub_token = session[:token] if session[:token]
    client.developer_key = 'AI39si50pWc6_Dsthhh-Wd49dkeffX6HX8TWhztcx_zgaTusACAnIhzlHS7xWZRPuNXJfkrgqFJRUu1WL17WH11iKWMjYQzNxQ'
    json = JSON.parse(client.get('https://gdata.youtube.com/feeds/api/users/default/recommendations').body)
    respond_to do |format|
      format.json { json }
    end
  end

  def login
    client = GData::Client::YouTube.new
    next_url = 'http://localhost:3000/sign_up'
    secure = false  # set secure = true for signed AuthSub requests
    sess = true
    authsub_link = client.authsub_url(next_url, secure, sess)
    redirect_to authsub_link
  end

  def sign_up
    client = GData::Client::YouTube.new
    client.authsub_token = params[:token] # extract the single-use token from the URL query params
    session[:token] = client.auth_handler.upgrade()
    redirect_to '/'
  end

end
