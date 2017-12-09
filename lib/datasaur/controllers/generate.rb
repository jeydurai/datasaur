# generate command handler

class BookingGenerator
  def initialize(report_opts, mongo_opts, args)
    @owner         = report_opts[:owner]
    @hist          = report_opts[:hist]
    @fields_config = parse_args args
    @model         = BookingDump.new(choose_model, report_opts[:dump_reqd], report_opts[:path], mongo_opts)
  end

  def choose_model
    case @owner
    when :sudhir
      COMBookingDump.new(@hist, @fields_config)
    when :tm
      SLTLBookingDump.new(@hist, @fields_config)
    when :mukund
      SWGEOBookingDump.new(@hist, @fields_config)
    when :vipul
      NEGEOBookingDump.new(@hist, @fields_config)
    when :fakhrudhin
      BDBookingDump.new(@hist, @fields_config)
    else
      raise "[Runtime Error]: Owner unfound!"
    end
  end

  def parse_args args
    fields_config = { add: [], discard: [] }
    args.each do |arg|
      config = arg.split(/[:|]/)
      if (config.first.strip.to_sym == :a) or (config.first.strip.to_sym == :add) or (config.first.strip.to_sym == :include) or \
          (config.first.strip.to_sym == :insert) or (config.first.strip.to_sym == :unshift)
        fields_config[:add] << config[1].strip
      elsif (config.first.strip.to_sym == :r) or (config.first.strip.to_sym == :remove) or (config.first.strip.to_sym == :exclude) or \
        (config.first.strip.to_sym == :discard) or (config.first.strip.to_sym == :shift)
        fields_config[:discard] << config[1].strip
      else
        raise "[Runtime Error]: arguments #{args.inspect} are hard to parse!"
      end
    end
    fields_config
  end
  
  def generate
    @model.read_data
  end

  public :generate
  private :choose_model, :parse_args
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


