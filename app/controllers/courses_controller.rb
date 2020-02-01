class CoursesController < ApplicationController
  respond_to :html, :json

  def index
    @years, @months, @days, @courses = [], [], [], {}
    @year, @month, @day = params[:year], params[:month], params[:day]

    @lang_code, @teacher_name = params[:language], params[:teacher]
    #todo handle non existant values ...
    teacher = Teacher.find_by(name: @teacher_name) unless @teacher_name.nil?
    language = Language.find_by(code: @lang_code) unless @lang_code.nil?

    courses = Course.all
    courses = courses.with_language(language) unless language.nil?
    courses = courses.with_teacher(teacher) unless teacher.nil?
    courses = courses.available

    if @year
      if @month
        if @day
          @courses = Hash.new { |h, k| h[k] = [] }
          courses.on_day(@year.to_i, @month.to_i, @day.to_i).each do | course |
            @courses[course.time_slot.hour].push(course)
          end
        else
          @days = courses.days(@year.to_i, @month.to_i)
        end
      else
        @months = courses.months(@year.to_i)
      end
    else
      @years = courses.years
    end
  end

  def show
    @course = Course.find(params[:id])
  end

  def list
    @courses = current_user.teacher_profile.courses.future.order(time_slot: :asc)
  end

  def create
    post_params = params.require(:course).permit(:time_slot, :zoom_url)
    time_slot = DateTime.parse(post_params[:time_slot])
    @course = current_user.teacher_profile.courses.new(time_slot: time_slot, zoom_url: post_params[:zoom_url])
    flash[:success] = 'Course was successfully created.' if @course.save
    redirect_back fallback_location: root_path
  end

  def update
    post_params = params.require(:course).permit(:teacher_id, :time_slot, :zoom_url)
    flash[:success] = 'Course was successfully updated.' if @course.update(post_params)
    respond_with @course
  end

##  def destroy
##    flash[:success] = 'Course was successfully destroyed.' if @course.
##  end

  def sign_up
    course = Course.find(params[:id])
    Course.transaction do
      course.student = current_user
      course.language = Language.find(params[:language_id])
      course.save

      current_user.tickets -= 1
      current_user.save
    end

    flash[:success] = "Signed up for a [#{course.language.name}] course with [#{course.teacher.user.username}] at [#{course.time_slot}]."
    # TODO send notification mail here
    redirect_to courses_path
  end
end
