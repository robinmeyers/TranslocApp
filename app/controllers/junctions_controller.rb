class JunctionsController < ApplicationController

  def get_junctions

    if params[:chr] && params[:rstart] && params[:rend]
      @junctions = Library.find(params[:library_id]).junctions.where(rname: params[:rname]).where(junction: params[:tstart]..params[:tend])
    elsif params[:chr]
      @junctions = Library.find(params[:library_id]).junctions.where(rname: params[:rname])
    else
      @junctions = Library.find(params[:library_id]).junctions
    end
    # respond_to do |format|
      # format.json { 
        render json: @junctions, only: [:rname, :junction, :strand]
    # end
  end

end