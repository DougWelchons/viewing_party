class CastController < ApplicationController
  def show
    @show = CastFacade.new(params[:id], 40)
  end
end
