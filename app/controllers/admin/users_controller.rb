class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
    render :layout => 'hub'
  end

  def show
    authorize! :show, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    @eve = init_eve_api(@user)
    render :layout => 'hub'
  end

  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to admin_users_path, :notice => "User updated."
    else
      redirect_to admin_users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to admin_users_path, :notice => "User deleted."
    else
      redirect_to admin_users_path, :notice => "Can't delete yourself."
    end
  end

  private
  def init_eve_api(user)
    begin
      EAAL.cache = EAAL::Cache::FileCache.new
      EAAL::API.new(user.apikey,user.secretkey)
    rescue EAAL::Exception::EveAPIException => e
      flash[:notice] = "#{e.message}"
      render "show"
    end
  end
end
