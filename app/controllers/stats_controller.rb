# frozen_string_literal: true

class StatsController < ApplicationController
  include ::TutorScheduler::StatsBuilder

  def courses_hourly
    start_date = Date.parse(params[:start_date]).beginning_of_day
    end_date = Date.parse(params[:end_date]).end_of_day
    courses = Course.all
    courses = courses.where(time_slot: start_date..end_date) unless start_date.blank? || end_date.blank?
    courses = courses.group('extract(dow from time_slot)::integer',
                            'extract(hour from time_slot)::integer')
    days = [[0, 'S'], [1, 'M'], [2, 'T'], [3, 'W'], [4, 'T'], [5, 'F'], [6, 'S']]
    @stats = build_array_stats courses.signed_up, courses.open, days, 7..22
  end

  def courses_teachers
    courses = Course.where('extract(year from time_slot)::integer = ?', params[:year].to_i)
    teachers = courses.joins(:teacher).distinct.pluck(:teacher_id, 'teachers.name').to_h
    courses = courses.group(:teacher_id, 'extract(month from time_slot)::integer')
    @stats = build_array_stats courses.signed_up, courses.open, teachers, 1..12
  end

  def courses_languages
    courses = Course.where('extract(year from time_slot)::integer = ?', params[:year].to_i)
    languages =
      courses.joins(:language).distinct.pluck('languages.id', 'languages.name').to_set |
      courses.where(language: nil).joins(teacher: :languages).distinct.pluck('languages.id', 'languages.name').to_set
    signed_up = courses.signed_up.group(:language_id, 'extract(month from time_slot)::integer')
    courses = courses.open.joins(teacher: :languages).group('languages.id', 'extract(month from time_slot)::integer')
    @stats = build_array_stats signed_up, courses, languages, 1..12
  end

  def courses_teacher_monthly
    @stats = monthly_stats month_courses_by_teacher_name
  end

  def courses_language_monthly
    @stats = monthly_stats month_courses_by_language_name
  end

  def courses_teacher_weekly
    @stats = weekly_stats month_courses_by_teacher_name
  end

  def courses_language_weekly
    @stats = weekly_stats month_courses_by_language_name
  end
end
