json.extract! course, :id, :time_slot
if course.language.nil?
  json.language "-"
  json.student "-"
else
  json.language course.language.name
  json.student course.student.username
end
json.zoom_url course.zoom_url
