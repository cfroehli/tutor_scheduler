json.array! @courses do |course|
  json.partial! "teachers/course", course: course
  json.set! :actions do
    json.set_content_link course.content.blank? ? "#{link_to raw('<i class="fas fa-box"/> Content'), edit_course_path(course) }" : ""    
    json.set_feedback_link course.feedback.blank? ? "#{link_to raw('<i class="fas fa-comments"/> Feedback'), edit_course_path(course) }" : ""
  end
end
