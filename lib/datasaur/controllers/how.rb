# how.rb
# How functionalities


class How
  include Parser::Generator::Parsable

  def initialize(owner, mong_config, args)
    @owner       = owner
    @mong_config = mong_config
    @args        = args
    @metric      = false
    @period      = nil
  end

  public
  def tellme
    return 1 unless args_present?
    @metric, @period = parse_howis_args
    return 1 if args_error?
    execute
    puts "All done!"
  end

  private
  def args_error?
    @metric.nil?
  end

  def args_present?
    @args.length > 0
  end

  def execute
    raise "[Error:] Abstract method 'execute' called"
  end

end

class Commercial < How

  def initialize(mong_config, args)
    super(:sudhir, mong_config, args)
    @job = nil
  end

  def execute
    choose_job
    @job.run
  end

  private
  def choose_job
    case @metric
    when :tech_trending
      @job = TechTrending.new(@mong_config, @owner, @period)
    else
      @job = nil
    end
  end

end


