require 'csv'
require 'net/http'

module NCDCScraper
  def self.get_data(options)
    csv_data = []
    
    # get the months for the desired time range
    months = options[:time].to_a.map {|x| "#{x.year}#{"%02d" % x.month}"}.uniq
    
    months.each do |month|
      # get the data from the NCDC website...
      url = URI.parse('http://cdo.ncdc.noaa.gov/qclcd/QCLCD')
      response, data = Net::HTTP.post_form(url, {
        reqday: 'E',
        stnid: 'n/a',
        prior: 'N',
        qcname: 'VER2',
        'VARVALUE' => "14819#{month}",
        yearid: "14819#{month}",
        which: 'ASCII Download (Hourly Obs.) (10A)'
      })
    
      csv_data += CSV.parse(response.body)[8..-4]
      
      # Don't want to bother the NCDC...
      sleep(1)
    end

    # for each weather reading
    csv_data.each do |row|
      break unless row[12]
      
      # grab the time
      time = DateTime.parse("#{row[1]} #{row[2][0..1]}:#{row[3][2..3]}:00#{DateTime.now.zone}")

      # if the time is out of range, skip forward...
      next unless options[:time].include?(time)
      
      # grab the timestamp      
      iso_timestamp = time.to_s

      # and the dry bulb temperature, which you convert from farenheit to kelvin
      temp = ((row[10].to_f - 32) * (5 / 9.0)) + 273.15
      
      # print it to standard output
      puts "#{iso_timestamp},#{temp}"
    end
  end
end



NCDCScraper.get_data({
  time: DateTime.iso8601(ARGV[0])..DateTime.iso8601(ARGV[1])
})