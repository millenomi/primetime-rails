class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

	def passthru
	  render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
	end

  def google
	# You need to implement the method below in your model
    @user = User.find_for_google(env["omniauth.auth"], current_user)
    p env['omniauth.strategy']
    env.each_key { |x|
        puts x if x.starts_with?('omniauth')
    }
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.open:id_data"] = env["openid.ext1"]
      redirect_to new_user_registration_url
    end
  end

end