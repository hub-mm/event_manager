require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  strip_phone_number = phone_number.to_s.delete('-(). ')

  if strip_phone_number.length == 11 && strip_phone_number[0] == '1'
    strip_phone_number = strip_phone_number[1..-1]
  elsif strip_phone_number.length != 10
    return 'Invalid phone number.'
  end

  return strip_phone_number if strip_phone_number.length == 10
end

def register_period(reg, counts_period)
  time = Time.strptime(reg, '%m/%d/%Y %R').strftime('%H%M').to_i

  case time
  when 0..559
    counts_period[:night] += 1
  when 600..1159
    counts_period[:morning] += 1
  when 1200..1759
    counts_period[:afternoon] += 1
  when 1800..2359
    counts_period[:evening] += 1
  else
    return 'Invalid input.'
  end
  
  counts_period
end

def register_day(reg, count_day)
  day = Date.strptime(reg, '%m/%d/%Y %R').wday

  case day
  when 1
    count_day[:monday] += 1
  when 2
    count_day[:tuesday] += 1
  when 3
    count_day[:wednesday] += 1
  when 4
    count_day[:thursday] += 1
  when 5
    count_day[:friday] += 1
  when 6
    count_day[:saturday] += 1
  when 0
    count_day[:sunday] += 1
  else 
    return 'Invalid day.'
  end

  count_day
end

def register_hour(reg, count_hour)
  time = Time.strptime(reg, '%m/%d/%Y %R').strftime('%H%M').to_i
  
  case time
  when 0..59
    count_hour[:'00 - 01'] += 1
  when 100..159
    count_hour[:'01 - 02'] += 1
  when 200..259
    count_hour[:'02 - 03'] += 1
  when 300..359
    count_hour[:'03 - 04'] += 1
  when 400..459
    count_hour[:'04 - 05'] += 1
  when 500..559
    count_hour[:'05 - 06'] += 1
  when 600..659
    count_hour[:'06 - 07'] += 1
  when 700..759
    count_hour[:'07 - 08'] += 1
  when 800..859
    count_hour[:'08 - 09'] += 1
  when 900..959
    count_hour[:'09 - 10'] += 1
  when 1000..1059
    count_hour[:'10 - 11'] += 1
  when 1100..1159
    count_hour[:'11 - 12'] += 1
  when 1200..1259
    count_hour[:'12 - 13'] += 1
  when 1300..1359
    count_hour[:'13 - 14'] += 1
  when 1400..1459
    count_hour[:'14 - 15'] += 1
  when 1500..1559
    count_hour[:'15 - 16'] += 1
  when 1600..1659
    count_hour[:'16 - 17'] += 1
  when 1700..1759
    count_hour[:'17 - 18'] += 1
  when 1800..1859
    count_hour[:'18 - 19'] += 1
  when 1900..1959
    count_hour[:'19 - 20'] += 1
  when 2000..2059
    count_hour[:'20 - 21'] += 1
  when 2100..2159
    count_hour[:'21 - 22'] += 1
  when 2200..2259
    count_hour[:'22 - 23'] += 1
  when 2300..2359
    count_hour[:'23 - 24'] += 1
  else
    return 'Invalid time.'
  end

  count_hour
end

def find_best_ad_period(reg_period)
  best_period = reg_period.max_by { |key, value| value}
  puts "The best time of day to run ads would be in the #{best_period[0].capitalize} with #{best_period[1]} registrations."
  best_period
end

def find_best_ad_hour(reg_hour)
  best_hour = reg_hour.max_by { |key, value| value}
  puts "The best hour in the day to run ads would be #{best_hour[0]} with #{best_hour[1]} registrations."
  best_hour
end

def find_best_ad_day(reg_day)
  best_day = reg_day.max_by { |key, value| value}
  puts "The best day to run ads would be #{best_day[0].capitalize} with #{best_day[1]} registrations.\n\n"
  best_day
end

def find_best_ad_time(period, hour, day)
  puts "The best day to run ads would be #{day[0].capitalize} in the #{period[0].capitalize} inbetween #{hour[0]}.\n\n"
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end
  
contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

counts_period = {night: 0, morning: 0, afternoon: 0, evening: 0}
count_hour = {
'12 - 01': 0, 
'01 - 02': 0, 
'02 - 03': 0, 
'03 - 04': 0,
'04 - 05': 0,
'05 - 06': 0,
'06 - 07': 0,
'07 - 08': 0,
'08 - 09': 0,
'09 - 10': 0,
'10 - 11': 0,
'11 - 12': 0,
'12 - 13': 0,
'13 - 14': 0,
'14 - 15': 0,
'15 - 16': 0,
'16 - 17': 0,
'17 - 18': 0,
'18 - 19': 0,
'19 - 20': 0,
'20 - 21': 0,
'21 - 22': 0,
'22 - 23': 0,
'23 - 24': 0
}
count_day = {monday: 0, tuesday: 0, wednesday: 0, thursday: 0, friday: 0, saturday: 0, sunday: 0}

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  reg = row[:regdate]

  reg_period = register_period(reg, counts_period)
  best_ad_period = find_best_ad_period(reg_period)

  reg_hour = register_hour(reg, count_hour)
  best_ad_hour = find_best_ad_hour(reg_hour)
  
  reg_day = register_day(reg, count_day)
  best_ad_day = find_best_ad_day(reg_day)

  best_time = find_best_ad_time(best_ad_period, best_ad_hour, best_ad_day)

  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  
  legislators = legislators_by_zipcode(zipcode)
  
  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
