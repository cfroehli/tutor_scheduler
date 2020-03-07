# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

languages = [
  ['aa', 'Afar'],
  ['ab', 'Abkhazian'],
  ['af', 'Afrikaans'],
  ['ak', 'Akan'],
  ['am', 'Amharic'],
  ['ar', 'Arabic'],
  ['an', 'Aragonese'],
  ['as', 'Assamese'],
  ['av', 'Avaric'],
  ['ae', 'Avestan'],
  ['ay', 'Aymara'],
  ['az', 'Azerbaijani'],
  ['ba', 'Bashkir'],
  ['bm', 'Bambara'],
  ['be', 'Belarusian'],
  ['bn', 'Bengali'],
  ['bi', 'Bislama'],
  ['bo', 'Tibetan'],
  ['bs', 'Bosnian'],
  ['br', 'Breton'],
  ['bg', 'Bulgarian'],
  ['ca', 'Catalan'],
  ['cs', 'Czech'],
  ['ch', 'Chamorro'],
  ['ce', 'Chechen'],
  ['cu', 'Church Slavic'],
  ['cv', 'Chuvash'],
  ['kw', 'Cornish'],
  ['co', 'Corsican'],
  ['cr', 'Cree'],
  ['cy', 'Welsh'],
  ['da', 'Danish'],
  ['de', 'German'],
  ['dv', 'Dhivehi'],
  ['dz', 'Dzongkha'],
  ['el', 'Modern Greek (1453-)'],
  ['en', 'English'],
  ['eo', 'Esperanto'],
  ['et', 'Estonian'],
  ['eu', 'Basque'],
  ['ee', 'Ewe'],
  ['fo', 'Faroese'],
  ['fa', 'Persian'],
  ['fj', 'Fijian'],
  ['fi', 'Finnish'],
  ['fr', 'French'],
  ['fy', 'Western Frisian'],
  ['ff', 'Fulah'],
  ['gd', 'Scottish Gaelic'],
  ['ga', 'Irish'],
  ['gl', 'Galician'],
  ['gv', 'Manx'],
  ['gn', 'Guarani'],
  ['gu', 'Gujarati'],
  ['ht', 'Haitian'],
  ['ha', 'Hausa'],
  ['he', 'Hebrew'],
  ['hz', 'Herero'],
  ['hi', 'Hindi'],
  ['ho', 'Hiri Motu'],
  ['hr', 'Croatian'],
  ['hu', 'Hungarian'],
  ['hy', 'Armenian'],
  ['ig', 'Igbo'],
  ['io', 'Ido'],
  ['ii', 'Sichuan Yi'],
  ['iu', 'Inuktitut'],
  ['ie', 'Interlingue'],
  ['ia', 'Interlingua'],
  ['id', 'Indonesian'],
  ['ik', 'Inupiaq'],
  ['is', 'Icelandic'],
  ['it', 'Italian'],
  ['jv', 'Javanese'],
  ['ja', 'Japanese'],
  ['kl', 'Kalaallisut'],
  ['kn', 'Kannada'],
  ['ks', 'Kashmiri'],
  ['ka', 'Georgian'],
  ['kr', 'Kanuri'],
  ['kk', 'Kazakh'],
  ['km', 'Central Khmer'],
  ['ki', 'Kikuyu'],
  ['rw', 'Kinyarwanda'],
  ['ky', 'Kirghiz'],
  ['kv', 'Komi'],
  ['kg', 'Kongo'],
  ['ko', 'Korean'],
  ['kj', 'Kuanyama'],
  ['ku', 'Kurdish'],
  ['lo', 'Lao'],
  ['la', 'Latin'],
  ['lv', 'Latvian'],
  ['li', 'Limburgan'],
  ['ln', 'Lingala'],
  ['lt', 'Lithuanian'],
  ['lb', 'Luxembourgish'],
  ['lu', 'Luba-Katanga'],
  ['lg', 'Ganda'],
  ['mh', 'Marshallese'],
  ['ml', 'Malayalam'],
  ['mr', 'Marathi'],
  ['mk', 'Macedonian'],
  ['mg', 'Malagasy'],
  ['mt', 'Maltese'],
  ['mn', 'Mongolian'],
  ['mi', 'Maori'],
  ['ms', 'Malay'],
  ['my', 'Burmese'],
  ['na', 'Nauru'],
  ['nv', 'Navajo'],
  ['nr', 'South Ndebele'],
  ['nd', 'North Ndebele'],
  ['ng', 'Ndonga'],
  ['ne', 'Nepali'],
  ['nl', 'Dutch'],
  ['nn', 'Norwegian Nynorsk'],
  ['nb', 'Norwegian Bokmål'],
  ['no', 'Norwegian'],
  ['ny', 'Nyanja'],
  ['oc', 'Occitan (post 1500)'],
  ['oj', 'Ojibwa'],
  ['or', 'Oriya'],
  ['om', 'Oromo'],
  ['os', 'Ossetian'],
  ['pa', 'Panjabi'],
  ['pi', 'Pali'],
  ['pl', 'Polish'],
  ['pt', 'Portuguese'],
  ['ps', 'Pushto'],
  ['qu', 'Quechua'],
  ['rm', 'Romansh'],
  ['ro', 'Romanian'],
  ['rn', 'Rundi'],
  ['ru', 'Russian'],
  ['sg', 'Sango'],
  ['sa', 'Sanskrit'],
  ['si', 'Sinhala'],
  ['sk', 'Slovak'],
  ['sl', 'Slovenian'],
  ['se', 'Northern Sami'],
  ['sm', 'Samoan'],
  ['sn', 'Shona'],
  ['sd', 'Sindhi'],
  ['so', 'Somali'],
  ['st', 'Southern Sotho'],
  ['es', 'Spanish'],
  ['sq', 'Albanian'],
  ['sc', 'Sardinian'],
  ['sr', 'Serbian'],
  ['ss', 'Swati'],
  ['su', 'Sundanese'],
  ['sw', 'Swahili '],
  ['sv', 'Swedish'],
  ['ty', 'Tahitian'],
  ['ta', 'Tamil'],
  ['tt', 'Tatar'],
  ['te', 'Telugu'],
  ['tg', 'Tajik'],
  ['tl', 'Tagalog'],
  ['th', 'Thai'],
  ['ti', 'Tigrinya'],
  ['to', 'Tonga (Tonga Islands)'],
  ['tn', 'Tswana'],
  ['ts', 'Tsonga'],
  ['tk', 'Turkmen'],
  ['tr', 'Turkish'],
  ['tw', 'Twi'],
  ['ug', 'Uighur'],
  ['uk', 'Ukrainian'],
  ['ur', 'Urdu'],
  ['uz', 'Uzbek'],
  ['ve', 'Venda'],
  ['vi', 'Vietnamese'],
  ['vo', 'Volapük'],
  ['wa', 'Walloon'],
  ['wo', 'Wolof'],
  ['xh', 'Xhosa'],
  ['yi', 'Yiddish'],
  ['yo', 'Yoruba'],
  ['za', 'Zhuang'],
  ['zh', 'Chinese'],
  ['zu', 'Zulu']
]

languages.each do | code, name |
  lang_entry = Language.find_by(code: code)
  if lang_entry.nil?
    Language.new(code: code, name: name).save
  else
    lang_entry.name = name
    lang_entry.save
  end
end

u = User.find_by(username: 'toto')
if u.nil?
  u = User.new(username: 'toto', email: 'toto@hazeliris.com', password: 'totopass', admin: true)
  u.save

  t = u.tickets.new(initial_count: 10, remaining: 10)
  t.save

  t = u.tickets.new(initial_count: 10, remaining: 10, expiration: Date.today + 3.weeks)
  t.save
end

t = Teacher.find_by(user_id: u.id)
if t.nil?
  t = Teacher.new(name: u.username, user_id: u.id)
  t.save
  ['fr', 'en', 'es'].each do |lang_code|
    lang = Language.find_by(code: lang_code)
    tl = TeachedLanguage.new(teacher: t, language: lang, active: true)
    tl.save
  end
end

50.times do
  d = rand(-5..5).days.from_now.to_date.to_datetime.change(hour: rand(7..22))
  if Course.where(time_slot: d).empty?
    c = Course.new(teacher_id: t.id, time_slot: d, zoom_url: "zoom_url")
    c.save
  end
end

u = User.find_by(username: 'titi')
if u.nil?
  u = User.new(username: 'titi', email: 'titi@hazeliris.com', password: 'titipass')
  u.save

  t = u.tickets.new(initial_count: 10, remaining: 10)
  t.save

  t = u.tickets.new(initial_count: 10, remaining: 10, expiration: Date.today + 3.days)
  t.save
end
