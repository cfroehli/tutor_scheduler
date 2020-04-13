# frozen_string_literal: true

class CoursesController < ApplicationController
  respond_to :html, :json

  def index
    @years   = []
    @months  = []
    @days    = []
    @courses = []

    @year = params[:year]
    @month = params[:month]
    @day = params[:day]

    @lang_code = params[:language]
    @teacher_name = params[:teacher]

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
          courses.on_day(@year.to_i, @month.to_i, @day.to_i).each do |course|
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
    @course = find_course
  end

  def create
    days = params[:days].split(',')
    hours = params[:hours]
    zoom_url = params[:zoom_url]

    no_error = true
    days.each do |day|
      next if day.blank?

      hours.each do |hour|
        next if hour.blank?

        time_slot = DateTime.parse("#{day} #{hour}")
        course = current_user.teacher_profile.courses.new(time_slot: time_slot, zoom_url: zoom_url)
        no_error &= course.save
      end
    end
    flash[:success] = 'Courses were successfully created.' if no_error
    redirect_back fallback_location: root_path
  end

  def edit
    @course = find_course
  end

  def update
    post_params = params.require(:course).permit(:zoom_url, :content, :feedback)
    course = find_course
    if course.update(post_params)
      flash[:success] = 'Course was successfully updated.'
      CourseMailer.notify_feedback_update(course).deliver_later if course.feedback_changed?
    end
    redirect_back fallback_location: root_path
  end

  def sign_up
    course = find_course

    teacher_profile = current_user.teacher_profile
    unless teacher_profile.nil?
      if teacher_profile.id == course.teacher.id
        flash[:info] = 'Unable to sign up for your own course.'
        redirect_back fallback_location: root_path && return
      end

      teaching_slot = teacher_profile.courses.where(time_slot: course.time_slot)
      unless teaching_slot.empty?
        flash[:info] = 'Unable to sign up : You already have a teaching slot registered at the same time.'
        redirect_back fallback_location: root_path && return
      end
    end

    Course.transaction do
      course.student = current_user
      course.language = Language.find(params[:language_id])
      course.save

      current_user.use_ticket
    end

    CourseMailer.sign_up(course).deliver_later
    CourseMailer.reservation(course).deliver_later

    flash[:success] = "Signed up for a [#{course.language.name}] course with [#{course.teacher.user.username}] at [#{course.time_slot}]." # rubocop:disable Layout/LineLength
    redirect_to courses_path
  end

  private

  def find_course
    Course.find(params[:id])
  end
end
