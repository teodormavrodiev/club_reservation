class ClubsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :show_map]
  skip_after_action :verify_policy_scoped, only: [:index]

  def index
    @clubs = Club.all
    @date = Date.today

    if params.has_key?(:date) && params[:date].present?
      @date = params[:date]
      @clubs = Club.has_free_seats_on(params[:date], @clubs)
    end

    if params.has_key?(:location) && params[:location].present?
      @clubs = Club.is_in(params[:location], @clubs)
    end

    @hash = Gmaps4rails.build_markers(@clubs) do |club, marker|
      marker.lat club.latitude
      marker.lng club.longitude
      # marker.infowindow render_to_string(partial: "/clubs/map_box", locals: { club: club })
    end
  end

  def show
    @club = Club.find(params[:id])
    authorize @club

    @date = params[:date] || Date.today
  end

  def show_map
    @club = Club.find(params[:id])
    authorize @club

    @hash = Gmaps4rails.build_markers(@club) do |club, marker|
      marker.lat club.latitude
      marker.lng club.longitude
      # marker.infowindow render_to_string(partial: "/clubs/map_box", locals: { club: club })
    end
  end

end
