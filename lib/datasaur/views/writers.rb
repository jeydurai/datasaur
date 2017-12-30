# IO writers

class ExcelWriter
  require 'xlsxtream'

  @@row = 0
  attr_accessor :headers

  def initialize filename, sheetname, headers
    @filename  = filename
    @headers    = headers
  end

  def write_data data, booking
    Xlsxtream::Workbook.open(@filename) do |xlsx|
      xlsx.write_worksheet 'Sheet1' do |sheet|
        data.each do |d|
          @@row += 1
          print "[Process]: Writing [#{@@row}][#{data.length}]row(s)\b\r"
          #sheet << @headers if @@row == 1 and booking
          sheet << d
        end
      end
    end
    puts "\n\n[Info]: Writes completed!"
  end

  public :write_data
end

class MongoWriter
  def initialize dbname, collname, host: 'localhost', port: '27107'
    @dbname   = dbname
    @collname = collname
    @host     = host
    @port     = port
  end

  def write_data doc
    puts "[Unimplemented from <MongoWriter>]: #{doc.inspect}"
  end

end

class Writer
  def initialize writer
    @writer = writer
  end

  def write_data data, booking
    @writer.write_data data, booking
  end
end




