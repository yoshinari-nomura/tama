class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[ show edit update destroy ]
  before_action :set_courses_and_teaching_assistants, only: %i[ new create edit update ]

  # GET /assignments or /assignments.json
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1 or /assignments/1.json
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
    @assignment.course_id = params[:course_id]
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments or /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to assignment_url(@assignment), notice: "Assignment was successfully created." }
        format.json { render :show, status: :created, location: @assignment }

        # pass notice to create.turbo_stream.erb
        flash.now.notice = "Assignment was successfully created."
        format.turbo_stream {} # will be rendered by create.turbo_stream.erb
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }

        # In case error, we do not return turbo stream.
        # HTML render new (_form) will work.
        # Validation will be shown inline, no need to use flash.
      end
    end
  end

  # PATCH/PUT /assignments/1 or /assignments/1.json
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to assignment_url(@assignment), notice: "Assignment was successfully updated." }
        format.json { render :show, status: :ok, location: @assignment }

        # pass notice to update.turbo_stream.erb
        flash.now.notice = "Assignment assistant was successfully updated."
        format.turbo_stream {} # will be rendered by update.turbo_stream.erb
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }

        # In case error, we do not return turbo stream.
        # HTML render edit (_form) will work.
        # Validation will be shown inline, no need to use flash.
      end
    end
  end

  # DELETE /assignments/1 or /assignments/1.json
  def destroy
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to assignments_url, notice: "Assignment was successfully destroyed." }
      format.json { head :no_content }

      # pass notice to destroy.turbo_stream.erb
      flash.now.notice = "Assignment was successfully destroyed."
      format.turbo_stream {} # will be rendered by destroy.turbo_stream.erb
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_courses_and_teaching_assistants
      @courses = Course.all
      @teaching_assistants = TeachingAssistant.all
    end

    # Only allow a list of trusted parameters through.
    def assignment_params
      params.require(:assignment).permit(:course_id, :teaching_assistant_id, :description)
    end
end
