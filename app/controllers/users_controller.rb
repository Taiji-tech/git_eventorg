class UsersController < ApplicationController
  def show
    @nickname = current_user.nickname
    @events = current_user.events.page(params[:page]).per(5).order("start DESC")
  end
end
