class PartiesController < ApplicationController
  before_action :current_user
  before_action :set_movie, only: [:create]
  def new
    @movie = Movie.find_or_create_by(name: params[:title], duration: params[:duration],
                                     poster_path: params[:poster_path])
    @party = Party.new(movie_id: @movie.id, host_id: current_user.id, duration: @movie.duration)
  end

  def create
    @party = Party.create(party_params)
    if @party.save
      invite_friends
      flash[:notice] = 'Invites Sent'
      redirect_to dashboard_path
    else
      flash[:error] = 'Invites not sent, missing fields'
      render :new, obj: [@party, @movie]
    end
  end

  private

  def party_params
    params.require(:party).permit(:duration, :date, :start_time, :movie_id, :host_id)
  end

  def invite_friends
    if params[:party][:friend_check]
      params[:party][:friend_check].each do |friend|
        PartyFriend.create(party_id: @party.id, user_id: friend)
      end
    end
  end

  def set_movie
    @movie = Movie.find(params[:party][:movie_id])
  end
end
