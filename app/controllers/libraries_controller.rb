class LibrariesController < ApplicationController
  before_action :signed_in_researcher
  before_action :correct_researcher_or_admin, only: [:edit, :update, :destroy]
  before_action :store_edit_location, only: [:edit, :destroy]

  def new
    @sequencing ||= Sequencing.find(params[:sequencing_id])
    @library = @sequencing.libraries.build
    @library_import = LibraryImport.new()
  end

  def show
    @library = Library.find(params[:id])
    @junctions_count = @library.junctions.count
    gon.library = @library
    @assembly = Assembly.find_by(name: @library.assembly)
    @chromosomes = @assembly.chromosomes
  end 

  def create
    @library = current_researcher.libraries.build(library_params)
    @sequencing = Sequencing.find(params[:library][:sequencing_id])
    @library.sequencing = @sequencing
    if @library.save
      flash[:success] = @library.name + " was successfully created!"
      redirect_to sequencing_path(@library.sequencing)
    else
      @library_import = LibraryImport.new()
      render 'new'
    end
  end


  def edit
  end

  def update
    if @library.update_attributes(library_params)
      flash[:success] = "Library #{@library.name} metadata updated!"
      redirect_back_or(sequencing_path(@library.sequencing))
    else
      render 'edit'
    end
  end

  def destroy
    @library = Library.destroy(params[:id])
    flash[:success] = "Library #{@library.name} destroyed."
    redirect_back_or(sequencing_path(@library.sequencing))
  end

  def get_library_data

    @library = Library.find(params[:library_id])
    @assembly = Assembly.find_by(name: @library.assembly)
    if params[:chr]
      @junctions = @library.junctions.where(rname: params[:chr]).select("rname, junction, strand")
      @chromosomes = @assembly.chromosomes.where(name: params[:chr])
      @cytobands = @assembly.cytobands.where(chrom: params[:chr])
    else
      @junctions = @library.junctions
      @chromosomes = @assembly.chromosomes
      @cytobands = @assembly.cytobands
    end

    @data = {junctions: @junctions, chromosomes: @chromosomes, cytobands: @cytobands}
    # respond_to do |format|
      # format.json { 
        render json: @data
    # end
  end

  private

    def library_params
      params.require(:library).permit(:name, 
        :assembly, :brkchr, :brkstart, :brkend, :brkstrand, :mid, :primer,
        :adapter, :breaksite, :cutter, :description)
    end

    def correct_researcher_or_admin
      @library = Library.find(params[:id])
      redirect_to(root_url) unless current_researcher?(@library.researcher) ||
                                      current_researcher.admin?
    end

    def store_edit_location
      session[:return_to] = params[:return_to]
    end
end