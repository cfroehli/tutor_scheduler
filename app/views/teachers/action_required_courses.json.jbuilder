# frozen_string_literal: true

json.array! @courses do |course|
  json.partial! 'teachers/course', course: course
  json.set! :actions do
    if course.content.blank?
      json.set_content_link link_to(raw('<i class="fas fa-box"/> Content'), edit_course_path(course)).to_s # rubocop:disable Rails/OutputSafety
    else
      json.set_content_link ''
    end

    if course.feedback.blank?
      json.set_feedback_link link_to(raw('<i class="fas fa-comments"/> Feedback'), edit_course_path(course)).to_s # rubocop:disable Rails/OutputSafety
    else
      json.set_feedback_link ''
    end
  end
end
