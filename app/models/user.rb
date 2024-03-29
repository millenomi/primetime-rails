class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

	def self.find_for_google(access_token, signed_in_resource=nil)
	  	data = access_token['user_info']
	  	p access_token
	    if user = User.find_by_email(data["email"])
	      user
	    else # Create a user with a stub password.
	      User.create!(:email => data["email"], :password => Devise.friendly_token[0,20])
	    end
	end

end
