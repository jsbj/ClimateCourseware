require 'csv'
require 'net/http'


module NCDCScraper
  def self.get_data # (time, location)
    url = URI.parse('http://cdo.ncdc.noaa.gov/qclcd/QCLCD')
    response, data = Net::HTTP.post_form(url, {
      reqday: 'E',
      stnid: 'n/a',
      prior: 'N',
      qcname: 'VER2',
      'VARVALUE' => 14819201212,
      yearid: 14819201212,
      which: 'ASCII Download (Hourly Obs.) (10A)'
    })
    
    csv_data = CSV.parse(response.body)[8..-1]
    
    csv_data.each do |row|
      break unless row[12]
      
      iso_timestamp = DateTime.parse("#{row[1]} #{row[2][0..1]}:#{row[3][2..3]}:00#{DateTime.now.zone}").to_s
      temp = ((row[10].to_f - 32) * (5 / 9.0)) + 273.15
      
      puts "#{iso_timestamp},#{temp}"
    end
  end
end

NCDCScraper.get_data