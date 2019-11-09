require 'pp'
require 'date'

$DEBUG = true
today = Date.today
today_month_day = ('%02d' % today.month ) + ('%02d' % today.day)
if $DEBUG
  PP.pp today_month_day, $stderr
end
quarter_boundaries = {
  '1' => ['01/01', '03/31'],
  '2' => ['04/01', '06/30'],
  '3' => ['07/01', '09/30'],
  '4' => ['10/01', '12/31'],
}

quarter_starts = {
  '0401' => '1',
  '0701' => '2',
  '1001' => '3',
}

current_quarter = '4'

quarter_starts.each do |quarter_boundary, quarter|
  if today_month_day < quarter_boundary
    current_quarter = quarter
  end
end
if $DEBUG
  PP.pp "Current quarter is #{current_quarter}" , $stderr
  PP.pp quarter_boundaries[current_quarter], $stderr
end
