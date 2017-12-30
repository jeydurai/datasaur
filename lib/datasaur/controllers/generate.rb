# generate command handler

class BookingGenerator
  include Parser::Generator::Parsable
  include Configurator::Generator::Configurable

  def initialize(report_opts, mongo_opts, args)
    @time          = Time.now.strftime "%Y-%m-%d_%H-%M-%S"
    @owner         = report_opts[:owner]
    @hist          = report_opts[:hist]
    @dump_reqd     = report_opts[:dump_reqd]
    @prodserv      = report_opts[:prodserv]
    @fields_config = parse_args args
    @spec_model    = choose_model :booking
    @spec_model.configure
    @out_file      = File.join(report_opts[:path], "#{@spec_model.name}_BookingDump#{@time}.xlsx")
    @model         = BookingDump.new(
      @spec_model, 
      Writer.new(ExcelWriter.new(@out_file, @spec_model.name, @spec_model.headers)), 
      mongo_opts
    )
  end

  def generate
    @model.read_data
    @model.write_data
    1
  end

  def read_data
    @model.read_data
  end

  public :generate, :read_data
end


class SFDCGenerator
  include Parser::Generator::Parsable
  include Configurator::Generator::Configurable

  def initialize(report_opts, mongo_opts, args)
    @time          = Time.now.strftime "%Y-%m-%d_%H-%M-%S"
    @owner         = report_opts[:owner]
    @hist          = report_opts[:hist]
    @dump_reqd     = report_opts[:dump_reqd]
    @prodserv      = report_opts[:prodserv]
    @fields_config = parse_args args
    @spec_model    = choose_model :sfdc
    @spec_model.configure
    @out_file      = File.join(report_opts[:path], "#{@spec_model.name}_SFDCDump#{@time}.xlsx")
    @model         = SFDCDump.new(
      @spec_model, 
      Writer.new(ExcelWriter.new(@out_file, @spec_model.name, @spec_model.headers)), 
      mongo_opts
    )
  end

  def generate
    @model.read_data
    @model.write_data booking: false
    1
  end

  def read_data
    @model.read_data
  end

  public :generate, :read_data
end


class Generator

  attr_accessor :generator

  def initialize(report_opts, mongo_opts, args)
    @name        = report_opts[:name]
    @report_opts = report_opts
    @mongo_opts  = mongo_opts
    @args        = args
    @generator   = choose_generator
  end

  def choose_generator
    case @name
    when :booking
      BookingGenerator.new(@report_opts, @mongo_opts, @args)
    when :sfdc
      SFDCGenerator.new(@report_opts, @mongo_opts, @args)
    else
      raise "[Runtime Error]: Report name unfound!"
    end
  end

  def generate
    @generator.generate
  end

  private :choose_generator
  public :generate
end


