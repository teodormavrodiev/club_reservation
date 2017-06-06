class ClubsController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]
  def index
    @clubs = Club.all
    @date = params[:date] || Date.today
  end

  def show
    @club = Club.find(params[:id])
    @date = params[:date] || Date.today
  end
end
