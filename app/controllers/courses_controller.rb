class CoursesController < ApplicationController
  respond_to :html, :json

  def index
    @year, @month, @day = params[:year], params[:month], params[:day]
    @years, @months, @days, @courses = [], [], [], {}
    if @year
      if @month
        if @day
          @courses = Hash.new { |h, k| h[k] = [] }
          Course.search(date: Date.new(@year.to_i, @month.to_i, @day.to_i)).each do |course|
            time_slot_hour = course.time_slot.hour
            @courses[time_slot_hour].push(course)
          end
        else
          @days = Course.available.days(@year.to_i, @month.to_i)
        end
      else
        @months = Course.available.months(@year.to_i)
      end
    else
      @years = Course.available.years
    end
  end

  def show
    @course = Course.find(params[:id])
  end

  def new
    @course = Course.new
  end

  def list
    @courses = current_user.teacher_profile.courses.future.order(time_slot: :asc)
  end

  def create
    time_slot = DateTime.parse(params.require(:course).permit(:time_slot)[:time_slot])
    @course = current_user.teacher_profile.courses.new(time_slot: time_slot)
    flash[:success] = 'Course was successfully created.' if @course.save
    redirect_to new_course_path
  end

  def update
    flash[:success] = 'Course was successfully updated.' if @course.update(post_params)
    respond_with @course
  end

##  def destroy
##    flash[:success] = 'Course was successfully destroyed.' if @course.
##  end

  def sign_up
    Course.transaction do
      course = Course.find(params[:id])
      course.student = current_user
      course.language = Language.find(params[:language_id])
      course.save
      current_user.tickets -= 1
      current_user.save
    end
    flash[:success] = 'Signed up'
    redirect_to courses_path
  end

  private
  def post_params
    params.require(:course).permit(:teacher_id, :time_slot)
  end
end
