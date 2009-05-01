class UsersController < ApplicationController
  
  before_filter :login_required, :except=>[:new]
  
  def index
    
  end

  # render new.rhtml
  def new
    @user = User.new
  end
  
  def edit
    @user = User.find(current_user)
  end
  
  def show
    @user = User.find(current_user) 
    if @user.twitter_username != nil
      client = authorize_twitter
      
      @statuses = client.user_timeline
    end
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end
  
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def self.consumer
    # The readkey and readsecret below are the values you get during registration
    OAuth::Consumer.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, { :site=>"http://twitter.com" })
  end
  
  def send_tweet
    @user = User.find(current_user)
    client = authorize_twitter
    if client.update(params[:tweet])
      flash[:notice] = 'Your tweet went through'
    else
      flash[:notice] = 'An error has occurred'
    end
    redirect_to root_path
  end
  
  def twitter_request
    @request_token = UsersController.consumer.get_request_token
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
    # Send to twitter.com to authorize
    redirect_to @request_token.authorize_url
    return
  end
  
  def callback
    @request_token = OAuth::RequestToken.new(UsersController.consumer,
    session[:request_token],
    session[:request_token_secret])
    # Exchange the request token for an access token.
    @access_token = @request_token.get_access_token
    @response = UsersController.consumer.request(:get, '/account/verify_credentials.json',
    @access_token, { :scheme => :query_string })
    case @response
    when Net::HTTPSuccess
    user_info = JSON.parse(@response.body)
    unless user_info['screen_name']
      flash[:notice] = "Authentication failed"
      redirect_to :action => :index
      return
    end
      # We have an authorized user, save the information to the database.
      @user = User.find(current_user)
      @user.twitter_token = @access_token.token
      @user.twitter_secret = @access_token.secret
      @user.twitter_username = user_info['screen_name']
      @user.save!
      # Redirect to the show page
      redirect_to(@user)
    else
      RAILS_DEFAULT_LOGGER.error "Failed to get user info via OAuth"
      # The user might have rejected this application. Or there was some other error during the request.
      flash[:notice] = "Authentication failed"
      redirect_to :action => :index
      return
    end
  end
  
  private
  def authorize_twitter
    oauth = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    oauth.authorize_from_access("#{@user.twitter_token}", "#{@user.twitter_secret}")
    return Twitter::Base.new(oauth)
    
  end
  
end
