class RatingsController < ApplicationController

  def create
    @reservation = Reservation.find(params[:reservation_id])
    club = @reservation.tables.first.club
    score = params["score"]
    information = params["Club Feedback"]
    rating = Rating.new
    rating.information = information
    rating.score = score
    rating.club = club
    rating.user = current_user

    authorize rating
    rating.save!

    redirect_to reservations_path
  end

  def new
    @reservation = Reservation.find(params[:reservation_id])
    club = @reservation.tables.first.club
    @rating = Rating.new
    @rating.club = club

    authorize @rating
  end

end
