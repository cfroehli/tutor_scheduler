# frozen_string_literal: true

class StatsController < ApplicationController
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

  private

  def build_stats(signed_up_stats, open_stats, key)
    open_count = open_stats[key] || 0
    signed_up_count = signed_up_stats[key] || 0
    total_count = open_count + signed_up_count
    return { text: nil, ratio: -1 } if total_count.zero?

    ratio = 100.0 * (signed_up_count.to_f / total_count)
    { text: "#{signed_up_count} / #{total_count}<br/>#{ratio.round(2)}%", ratio: ratio }
  end

  def build_array_stats(signed_up, open, rows, columns)
    open_stats = open.count
    signed_up_stats = signed_up.count
    rows.map do |row_id, row_name|
      [row_name] + columns.map { |col_id| build_stats(signed_up_stats, open_stats, [row_id, col_id]) }
    end
  end

  def build_details_stats(courses, columns)
    open_stats = courses.open.count
    signed_up_stats = courses.signed_up.count
    columns.map { |col_id| build_stats(signed_up_stats, open_stats, col_id) }
  end

  def stats(courses, group_by, group_range)
    courses = courses.group group_by
    [build_details_stats(courses, group_range)]
  end

  def monthly_stats(courses)
    stats courses, 'extract(day from time_slot)::integer', 1..31
  end

  def weekly_stats(courses)
    stats courses, 'extract(dow from time_slot)::integer', 0..6
  end

  def limit_to_month(courses, year, month)
    courses
      .where 'extract(year from time_slot)::integer = ? and extract(month from time_slot)::integer = ?',
             year, month
  end

  def month_courses_by_teacher_name
    teacher = Teacher.find_by(name: params[:item])
    limit_to_month teacher.courses, params[:year].to_i, params[:month].to_i
  end

  def month_courses_by_language_name
    language = Language.find_by(name: params[:item])
    limit_to_month Course.with_language(language), params[:year].to_i, params[:month].to_i
  end
end
