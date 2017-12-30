# Modules to contains IO related methods

require 'awesome_print'

module Booking
  module Readable
    def read_data
      puts "[Info]: Query Initializing..."
      counter = 0
      @model.queries.each do |q|
        counter += 1
        print "[Process]: Query No.: [#{counter}][#{@model.queries.length}]\b\r"
        agg(q) do |doc|
          if @header_switch
            @data << @model.headers
            @header_switch = false
          end
          @data << doc.values
        end
      end
    end

    public :read_data
  end
end


module SFDC
  module Readable
    def read_data
      puts "[Info]: Query Initializing..."
      counter = 0
      @model.queries.each do |q|
        counter += 1
        print "[Process]: Query No.: [#{counter}][#{@model.queries.length}]\b\r"
        find_doc(@model.queries[0]) do |doc|
          if @header_switch
            @data << doc.keys
            @header_switch = false
          end
          @data << doc.values
        end
      end

    end

    public :read_data
  end
end


module Writeable
  def write_data booking: true
    puts "\n\n[Info]: Writing Initializing..."
    @writer.write_data(@data, booking)
  end

  public :write_data
end
