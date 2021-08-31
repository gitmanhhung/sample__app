class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration,
                only: [:edit, :update]
  before_action :check_pass_empty, only: [:update]

  def new; end

  def edit; end

  def update
    if @user.update user_params
      @user.update_column reset_digest: nil
      flash[:success] = t("user_mailer.pass_reset")
      redirect_to login_path
    else
      render :edit
    end
  end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t("user_mailer.Email_sent")
      redirect_to root_url
    else
      flash.now[:danger] = t("user_mailer.notfound")
      render :new
    end
  end

  private

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t "users.nil"
    redirect_to root_path
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t("user_mailer.acc_not_acti")
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t("user_mailer.Password_reset_has_expired")
    redirect_to new_password_reset_url
  end

  def check_pass_empty
    return unless params[:user][:password].empty?

    @user.errors.add(:password, t("user_mailer.pass_empty"))
    render :edit
  end
end
