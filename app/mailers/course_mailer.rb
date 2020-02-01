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
end
