# frozen_string_literal: true

class CoursesController < ApplicationController
  respond_to :html, :json

  before_action :set_course, only: %i[show edit update sign_up]
  before_action :ensure_slot_allowed, only: %i[sign_up]
  before_action :ensure_has_tickets, only: %i[sign_up]

  def index
    @years   = []
    @months  = []
    @days    = []
    @courses = []

    @year = params[:year]
    @month = params[:month]
    @day = params[:day]

    courses = Course.all

    @lang_code = params[:language]
    if @lang_code.present?
      language = Language.find_by(code: @lang_code)
      courses = courses.with_language(language) unless language.nil?
    end

    @teacher_name = params[:teacher]
    if @teacher_name.present?
      teacher = Teacher.find_by(name: @teacher_name)
      courses = courses.with_teacher(teacher) unless teacher.nil?
    end

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
  end

  def create
    days = params[:days].split(',').reject(&:blank?)
    hours = params[:hours].reject(&:blank?).map(&:to_i).reject { |h| h < 7 || h > 22 }
    zoom_url = params[:zoom_url]

    no_error = true
    days.each do |day|
      hours.each do |hour|
        time_slot = DateTime.parse("#{day} #{hour}")
        course = current_user.teacher_profile.courses.new(time_slot: time_slot, zoom_url: zoom_url)
        no_error &= course.save
      end
    end

    flash[:success] = 'Courses were successfully created.' if no_error
    redirect_back fallback_location: root_path
  end

  def edit
  end

  def update
    post_params = params.require(:course).permit(:zoom_url, :content, :feedback)
    if @course.update(post_params)
      flash[:success] = 'Course was successfully updated.'
    end
    redirect_back fallback_location: root_path
  end

  def sign_up
    if @course.sign_up(current_user, params[:language_id])
      flash[:success] = "Signed up for a [#{@course.language.name}] course with [#{@course.teacher.name}] at [#{@course.time_slot.in_time_zone}]."
    end
    redirect_to courses_path
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def ensure_slot_allowed
    teacher_profile = current_user.teacher_profile
    return if teacher_profile.nil?

    if teacher_profile.id == @course.teacher.id
      flash[:info] = 'Unable to sign up for your own course.'
      redirect_back fallback_location: root_path
      return
    end

    teaching_slot = teacher_profile.courses.where(time_slot: @course.time_slot)
    return if teaching_slot.empty?

    flash[:info] = 'Unable to sign up : You already have a teaching slot registered at the same time.'
    redirect_back fallback_location: root_path
  end

  def ensure_has_tickets
    return if current_user.remaining_tickets.positive?

    flash[:danger] = 'You need a ticket to reserve a course.'
    redirect_back fallback_location: root_path
  end
end
