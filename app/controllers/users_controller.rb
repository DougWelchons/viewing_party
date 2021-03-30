class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :login]
  def login
    @user = User.find_by(email: params[:email].downcase)
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to dashboard_path
    else
      flash.now[:error] = 'Invalid Email or Password'
      render './welcome/index'
    end
  end

  def dashboard
    @user = current_user
    @host_parties = Party.where(host_id: @user.id)
    @invited_parties = @user.parties
  end

  def new; end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to '/dashboard'
      flash[:success] = "Welcome, #{@user.name}!"
    else
      flash.now[:error] = 'All fields required. Passwords must match'
      render :new, obj: @user
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
