require 'pp'
require 'date'

$DEBUG = true
today = Date.today
if $DEBUG
  PP.pp "Today is: #{today}", $stderr
end

today_month_day = ('%02d' % today.month ) + ('%02d' % today.day)
if $DEBUG
  PP.pp "Today Month day: #{today_month_day}", $stderr
end
quarter_boundaries = {
  '1' => ['01/01', '03/31'],
  '2' => ['04/01', '06/30'],
  '3' => ['07/01', '09/30'],
  '4' => ['10/01', '12/31'],
}

quarter_starts = {
  '1001' => '3',
  '0701' => '2',
  '0401' => '1',
}

current_quarter = '4'
# order matters
quarter_starts.each do |quarter_boundary, quarter|
  if today_month_day < quarter_boundary
    if $DEBUG
      $stderr.puts "Evaluating quarter #{quarter}"
    end
    current_quarter = quarter
    # order matters
    # break
  end
end
prev_quarters = {
  '1' => '4',
  '2' => '1',
  '3' => '2',
  '4' => '3',
}
if $DEBUG
  PP.pp "Current is #{current_quarter}" , $stderr
end

report_quarter = (
if current_quarter == '1'
  4
else
  current_quarter.to_i - 1
end ).to_s

if $DEBUG
  PP.pp "Report quarter is #{report_quarter}" , $stderr
end

report_quarter  = prev_quarters[current_quarter]

if $DEBUG
  PP.pp "Report quarter is #{report_quarter}" , $stderr
end
if $DEBUG
  PP.pp quarter_boundaries[report_quarter], $stderr
end

report_year = if report_quarter == '4'
  today.year - 1
else
  today.year
end
PP.pp "Report Year is #{report_year}"
