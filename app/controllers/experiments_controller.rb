class ExperimentsController < ApplicationController
  before_action :signed_in_researcher

  def new
    @sequencing ||= Sequencing.find(params[:sequencing_id])
    @researcher = current_researcher
    @experiment = @sequencing.experiments.build(researcher: @researcher)
  end

  # def create
  #   @experiment = current_researcher.experiments.build(experiment_params)
  #   if @experiment.save
  #     flash[:success] = "Experiment created!"
  #     redirect_to sequencing_path(@experiment.sequencing)
  #   else
  #     @new_experiment = @experiment
  #     @sequencing = Sequencing.find(params[:experiment][:sequencing_id])
  #     render 'sequencings/show'

  #   end
  # end

  def create
    @experiment = current_researcher.experiments.build(experiment_params)
    if @experiment.save
      flash[:success] = @experiment.name + " was successfully created!"
      redirect_to sequencing_path(@experiment.sequencing)
    else
      @sequencing = Sequencing.find(params[:experiment][:sequencing_id])
      render 'new'
    end
  end


  def destroy
  end

  private

    def experiment_params
      params.require(:experiment).permit(:name, :sequencing_id, 
        :assembly, :brkchr, :brkstart, :brkend, :brkstrand, :mid, :primer,
        :adapter, :breaksite, :description)
    end
end