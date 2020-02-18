json.array! @courses do |course|
  json.partial! "teachers/course", course: course
  unless course.student.nil?
    json.courses_history_link "#{link_to course.student.username, courses_history_user_path(course.student)}"
  end
end
