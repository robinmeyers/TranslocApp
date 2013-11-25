class JunctionsController < ApplicationController

  def get_junctions

    if params[:chr] && params[:rstart] && params[:rend]
      @junctions = Library.find(params[:library_id]).junctions.where(rname: params[:chr]).where(junction: params[:rstart]..params[:rend])
    elsif params[:chr]
      @junctions = Library.find(params[:library_id]).junctions.where(rname: params[:chr])
    else
      @junctions = Library.find(params[:library_id]).junctions
    end
    # respond_to do |format|
      # format.json { 
        render json: @junctions, only: [:rname, :junction, :strand]
    # end
  end

end