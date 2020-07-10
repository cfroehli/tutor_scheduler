# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

languages = [
  %w[aa Afar],
  %w[ab Abkhazian],
  %w[af Afrikaans],
  %w[ak Akan],
  %w[am Amharic],
  %w[ar Arabic],
  %w[an Aragonese],
  %w[as Assamese],
  %w[av Avaric],
  %w[ae Avestan],
  %w[ay Aymara],
  %w[az Azerbaijani],
  %w[ba Bashkir],
  %w[bm Bambara],
  %w[be Belarusian],
  %w[bn Bengali],
  %w[bi Bislama],
  %w[bo Tibetan],
  %w[bs Bosnian],
  %w[br Breton],
  %w[bg Bulgarian],
  %w[ca Catalan],
  %w[cs Czech],
  %w[ch Chamorro],
  %w[ce Chechen],
  ['cu', 'Church Slavic'],
  %w[cv Chuvash],
  %w[kw Cornish],
  %w[co Corsican],
  %w[cr Cree],
  %w[cy Welsh],
  %w[da Danish],
  %w[de German],
  %w[dv Dhivehi],
  %w[dz Dzongkha],
  ['el', 'Modern Greek (1453-)'],
  %w[en English],
  %w[eo Esperanto],
  %w[et Estonian],
  %w[eu Basque],
  %w[ee Ewe],
  %w[fo Faroese],
  %w[fa Persian],
  %w[fj Fijian],
  %w[fi Finnish],
  %w[fr French],
  ['fy', 'Western Frisian'],
  %w[ff Fulah],
  ['gd', 'Scottish Gaelic'],
  %w[ga Irish],
  %w[gl Galician],
  %w[gv Manx],
  %w[gn Guarani],
  %w[gu Gujarati],
  %w[ht Haitian],
  %w[ha Hausa],
  %w[he Hebrew],
  %w[hz Herero],
  %w[hi Hindi],
  ['ho', 'Hiri Motu'],
  %w[hr Croatian],
  %w[hu Hungarian],
  %w[hy Armenian],
  %w[ig Igbo],
  %w[io Ido],
  ['ii', 'Sichuan Yi'],
  %w[iu Inuktitut],
  %w[ie Interlingue],
  %w[ia Interlingua],
  %w[id Indonesian],
  %w[ik Inupiaq],
  %w[is Icelandic],
  %w[it Italian],
  %w[jv Javanese],
  %w[ja Japanese],
  %w[kl Kalaallisut],
  %w[kn Kannada],
  %w[ks Kashmiri],
  %w[ka Georgian],
  %w[kr Kanuri],
  %w[kk Kazakh],
  ['km', 'Central Khmer'],
  %w[ki Kikuyu],
  %w[rw Kinyarwanda],
  %w[ky Kirghiz],
  %w[kv Komi],
  %w[kg Kongo],
  %w[ko Korean],
  %w[kj Kuanyama],
  %w[ku Kurdish],
  %w[lo Lao],
  %w[la Latin],
  %w[lv Latvian],
  %w[li Limburgan],
  %w[ln Lingala],
  %w[lt Lithuanian],
  %w[lb Luxembourgish],
  %w[lu Luba-Katanga],
  %w[lg Ganda],
  %w[mh Marshallese],
  %w[ml Malayalam],
  %w[mr Marathi],
  %w[mk Macedonian],
  %w[mg Malagasy],
  %w[mt Maltese],
  %w[mn Mongolian],
  %w[mi Maori],
  %w[ms Malay],
  %w[my Burmese],
  %w[na Nauru],
  %w[nv Navajo],
  ['nr', 'South Ndebele'],
  ['nd', 'North Ndebele'],
  %w[ng Ndonga],
  %w[ne Nepali],
  %w[nl Dutch],
  ['nn', 'Norwegian Nynorsk'],
  ['nb', 'Norwegian Bokmål'],
  %w[no Norwegian],
  %w[ny Nyanja],
  ['oc', 'Occitan (post 1500)'],
  %w[oj Ojibwa],
  %w[or Oriya],
  %w[om Oromo],
  %w[os Ossetian],
  %w[pa Panjabi],
  %w[pi Pali],
  %w[pl Polish],
  %w[pt Portuguese],
  %w[ps Pushto],
  %w[qu Quechua],
  %w[rm Romansh],
  %w[ro Romanian],
  %w[rn Rundi],
  %w[ru Russian],
  %w[sg Sango],
  %w[sa Sanskrit],
  %w[si Sinhala],
  %w[sk Slovak],
  %w[sl Slovenian],
  ['se', 'Northern Sami'],
  %w[sm Samoan],
  %w[sn Shona],
  %w[sd Sindhi],
  %w[so Somali],
  ['st', 'Southern Sotho'],
  %w[es Spanish],
  %w[sq Albanian],
  %w[sc Sardinian],
  %w[sr Serbian],
  %w[ss Swati],
  %w[su Sundanese],
  %w[sw Swahili],
  %w[sv Swedish],
  %w[ty Tahitian],
  %w[ta Tamil],
  %w[tt Tatar],
  %w[te Telugu],
  %w[tg Tajik],
  %w[tl Tagalog],
  %w[th Thai],
  %w[ti Tigrinya],
  ['to', 'Tonga (Tonga Islands)'],
  %w[tn Tswana],
  %w[ts Tsonga],
  %w[tk Turkmen],
  %w[tr Turkish],
  %w[tw Twi],
  %w[ug Uighur],
  %w[uk Ukrainian],
  %w[ur Urdu],
  %w[uz Uzbek],
  %w[ve Venda],
  %w[vi Vietnamese],
  %w[vo Volapük],
  %w[wa Walloon],
  %w[wo Wolof],
  %w[xh Xhosa],
  %w[yi Yiddish],
  %w[yo Yoruba],
  %w[za Zhuang],
  %w[zh Chinese],
  %w[zu Zulu],
]

languages.each do |code, name|
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
  u = User.new(username: 'toto', email: 'toto@hazeliris.com', password: 'totopass')
  u.add_role :admin
  u.save

  t = u.tickets.new(initial_count: 10, remaining: 10)
  t.save

  t = u.tickets.new(initial_count: 10, remaining: 10, expiration: Time.zone.today + 3.weeks)
  t.save
end

t = Teacher.find_by(user_id: u.id)
if t.nil?
  t = Teacher.new(name: u.username, user_id: u.id)
  t.save
  %w[fr en es].each do |lang_code|
    lang = Language.find_by(code: lang_code)
    tl = TeachedLanguage.new(teacher: t, language: lang, active: true)
    tl.save
  end
end

50.times do
  d = rand(-5..5).days.from_now.to_date.to_datetime.change(hour: rand(7..22))
  if Course.where(time_slot: d).empty?
    c = Course.new(teacher_id: t.id, time_slot: d, zoom_url: 'zoom_url')
    c.save
  end
end

u = User.find_by(username: 'titi')
if u.nil?
  u = User.new(username: 'titi', email: 'titi@hazeliris.com', password: 'titipass')
  u.save

  t = u.tickets.new(initial_count: 10, remaining: 10)
  t.save

  t = u.tickets.new(initial_count: 10, remaining: 10, expiration: Time.zone.today + 3.days)
  t.save
end
