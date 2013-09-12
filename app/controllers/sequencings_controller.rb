class SequencingsController < ApplicationController

  before_action :signed_in_researcher
      
  def new
  end

  def index
    @uncompleted_sequencings = Sequencing.where(completed_on: nil)
    @completed_sequencings = Sequencing.where.not(completed_on: nil).paginate(page: params[:page])
  end

  def create
  end

  def show
    @sequencing = Sequencing.find(params[:id])
  end

  def update
  end

  def destroy
  end
end
