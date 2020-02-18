json.extract! course, :id, :time_slot, :zoom_url
if course.language.nil?
  json.language "-"
  json.student "-"
else
  json.language course.language.name
  json.student course.student.username
end
