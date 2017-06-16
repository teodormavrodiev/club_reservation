class RegistrationsController < Devise::RegistrationsController

  # def verify_phone_number
  #   @user = User.find(params[:id])
  #   raise
  #   redirect_to (root_path)
  # end

  private

  def sign_up_params
    params.require(:user).permit(:full_name, :phone_number, :email, :password, :password_confirmation, :photo)
  end

  def account_update_params
    params.require(:user).permit(:full_name, :phone_number, :email, :password, :password_confirmation, :current_password, :photo)
  end
end
