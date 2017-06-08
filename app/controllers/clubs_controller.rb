class ClubsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @clubs = policy_scope(Club)
    @date = params[:date] || Date.today
  end

  def show
    @club = Club.find(params[:id])
    authorize @club

    @date = params[:date] || Date.today
  end
end
