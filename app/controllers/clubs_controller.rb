class ClubsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :show_map]

  def index
    @clubs = policy_scope(Club)
    @date = params[:date] || Date.today

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
