class SequencingsController < ApplicationController

  before_action :signed_in_researcher
      
  def new
    @sequencing = Sequencing.new
  end

  def index
    @uncompleted_sequencings = Sequencing.where(completed_on: nil)
    @completed_sequencings = Sequencing.where.not(completed_on: nil).paginate(page: params[:page])
  end

  def create
    @sequencing = Sequencing.new(run: params[:sequencing][:run])
    if @sequencing.save
      flash[:success] = @sequencing.run + " successfully created"
      redirect_to @sequencing
    else
      flash.now[:error] = "Could not create new sequencing run"
      render 'new'
    end

  end

  def show
    @sequencing = Sequencing.find(params[:id])
    @experiments = @sequencing.experiments.paginate(page: params[:page])
  end

  def update
  end

  def mark_as_completed
    @sequencing = Sequencing.find(params[:id])
    @sequencing.update_attributes(completed_on: Date.today)
    flash[:success] = "Sequencing run marked as completed"
    redirect_to @sequencing
  end

  def destroy
  end

end
