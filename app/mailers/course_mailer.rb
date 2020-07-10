# frozen_string_literal: true

class CourseMailer < ApplicationMailer
  def sign_up(course)
    @course = course
    mail(
      to: @course.student.email,
      subject: 'Course sign up notification'
    )
  end

  def reservation(course)
    @course = course
    mail(
      to: @course.teacher.user.email,
      subject: 'Course sign up notification'
    )
  end

  def notify_feedback_update(course)
    @course = course
    mail(
      to: @course.student.email,
      subject: 'Course feedback update notification'
    )
  end
end
