class ResortController < ApplicationController

  def show
    @resort = Resort.find(resort_params[:id])
  end


  private

  def resort_params
    params.permit :id
  end
end