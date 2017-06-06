class CommentsController < ApplicationController

  def create
    comment = Comment.new
    comment.reservation_id = params[:reservation_id]
    comment.datetime = DateTime.now
    comment.information = params["Your Comment"]
    comment.user = current_user
    comment.save!
    redirect_to :back
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    comment = Comment.find(params[:id])
    comment.information = params["Your Comment"]
    comment.save!
    redirect_to reservations_path
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy!
    redirect_to reservations_path
  end
end
