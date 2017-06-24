require 'net/https'
require 'open-uri'
require 'json'

class RegistrationsController < Devise::RegistrationsController

  def phone_verification
    #send code
    #make some defense to make sure that the @user is same as current_user
    #and that phone isn't already verified
    @user = User.find(params[:id])

    data = {api_key: ENV['AUTHY_API_KEY'],
            via: "sms",
            country_code: 359,
            phone_number: "#{@user.phone_number}"
            }

    # x = Net::HTTP.post_form(URI.parse("https://api.authy.com/protected/json/phones/verification/start"), data)
    # response = JSON.parse(x.body)
    # check response is successful and act accordingly

  end

  def phone_verification_confirmation
    #check that code is accurate and redirect to home with a msg
    #set phone_verified to true in the model

    @user = User.find(params[:id])

    data = {api_key: ENV['AUTHY_API_KEY'],
            country_code: 359,
            phone_number: "#{@user.phone_number}",
            verification_code: params["Code"]
            }

    x = Net::HTTP.get(URI("https://api.authy.com/protected/json/phones/verification/check?" \
      "api_key=#{data[:api_key]}&" \
      "country_code=#{data[:country_code]}&" \
      "phone_number=#{data[:phone_number]}&" \
      "verification_code=#{data[:verification_code]}"))

    response = JSON.parse(x)
    #check code and response. If success do one, if else do other
    redirect_to root_path

  end

  def after_sign_up_path_for(resource)
    phone_verification_path(resource)
  end

  private

  def sign_up_params
    params.require(:user).permit(:full_name, :phone_number, :email, :password, :password_confirmation, :photo)
  end

  def account_update_params
    params.require(:user).permit(:full_name, :phone_number, :email, :password, :password_confirmation, :current_password, :photo)
  end
end
