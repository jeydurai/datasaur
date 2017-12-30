# Models for 'sfdc_dump' collection

class SFDCDump < MongoBase
  include SFDC::Readable
  include Writeable

  def initialize(model, writer, mongo_opts)
    super(mongo_opts[:host], mongo_opts[:port], mongo_opts[:dbname],'sfdc_dump')
    @model         = model
    @writer        = writer
    @data          = []
    @header_switch = true
  end

end


class COMSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_Sudhir'
    @node_field = 'sales_level_3'
    @nodes      = [ 'INDIA_COMM_1' ]
  end
end


class NEGEOSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_NEGEO_Vipul'
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_NE_GEO' ]
  end
end


class SLTLSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_SLTL_Tirtankar'
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_SL_TL' ]
  end
end


class SWGEOSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_SWGEO_Mukundhan'
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_SW_GEO' ]
  end
end


class BDSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_BD_Fakhrudhin'
    @node_field = 'sales_level_4'
    @nodes      = [ 'INDIA_COMM_BD' ]
  end
end


class SLTLSouthSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_SLTL_Rajeev'
    @node_field = 'rm_name'
    @nodes      = [ 'Rajeev Mariyil' ]
  end

end


class SLTLWestSFDCDump < SFDCQueryEngine

  attr_reader :queries, :headers, :name

  def initialize hist, prodserv, fields_config
    super
    @name       = 'Commercial_SLTL_Manoj'
    @node_field = 'rm_name'
    @nodes      = [ 'Manoj Joshi' ]
  end
end
