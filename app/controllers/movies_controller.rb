class MoviesController < ApplicationController
  def index
    @results = MovieFacade.search_results(params[:search], 40)
  end

  def show
    @movie = MovieFacade.movie_info(params[:id])
  end
end
