class SequencingsController < ApplicationController

  before_action :signed_in_researcher, except: [:index, :show]
      
  def new
    @sequencing = Sequencing.new
  end

  def index
    @uncompleted_sequencings = Sequencing.uncompleted
    @completed_sequencings = Sequencing.completed.paginate(page: params[:page])
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
    respond_to do |format|
      format.html
      format.txt { send_data @sequencing.experiments.to_txt(col_sep: "\t"), disposition: "attachment", filename: @sequencing.run + "_metadata.txt" }
      format.xlsx { render xlsx: "meta", disposition: "attachment", :filename => @sequencing.run + "_metadata.xlsx"}
    end
    # @experiment = current_researcher.experiments.build if signed_in?
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
