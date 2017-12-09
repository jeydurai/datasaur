# Models for 'booking_dump' collection

class BookingDump < MongoBase

  def initialize(model, dump_reqd, dump_path, mongo_opts)
    super(mongo_opts[:host], mongo_opts[:port], mongo_opts[:dbname],'booking_dump')
    @model   = model
    @model.configure
    @time    = Time.now.strftime "%Y-%m-%d_%H-%M-%S"
    @writer = Writer.new(ExcelWriter.new(File.join(dump_path, "#{model.name}_Dump#{@time}.xlsx"), model.name, model.headers))
    @data = []
  end

  public
  def read_data
    puts "[Info]: Query Initializing..."
    counter = 0
    @model.queries.each do |q|
      counter += 1
      print "[Process]: Query No.: [#{counter}][#{@model.queries.length}]\b\r"
      agg(q) do |doc|
        @data << doc.values
      end
    end
    puts "\n\n[Info]: Writing Initializing..."
    @writer.write_data(@data)
    1
  end

end


class COMBookingDump < QueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, fields_config
    super(hist, fields_config)
    @name       = 'Commercial_Sudhir'
    @queries    = {}
    @node_field = 'sales_level_3'
    @nodes      = [ 'INDIA_COMM_1' ]
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  public :configure
end


class NEGEOBookingDump < QueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, fields_config
    super(hist, fields_config)
    @name       = 'Commercial_NEGEO_Vipul'
    @queries = {}
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_NE_GEO' ]
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  public :configure
end


class SLTLBookingDump < QueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, fields_config
    super(hist, fields_config)
    @name       = 'Commercial_SLTL_Tirtankar'
    @queries = {}
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_SL_TL' ]
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  public :configure
end


class SWGEOBookingDump < QueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, fields_config
    super(hist, fields_config)
    @name       = 'Commercial_SWGEO_Mukundhan'
    @queries = {}
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_SW_GEO' ]
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  public :configure
end


class BDBookingDump < QueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, fields_config
    super(hist, fields_config)
    @name       = 'Commercial_BD_Fakhrudhin'
    @queries = {}
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_BD' ]
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  public :configure
end
