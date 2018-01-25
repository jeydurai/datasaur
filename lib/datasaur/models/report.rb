# report.rb
#

class Report < MongoBase

  attr_accessor :query, :data_cube

  def initialize(host, port, dbname, collname)
    super
    @mongo_opts = { host: host, port: port, dbname: dbname, collname: collname}
    @prod_serv = 'products'
    @query     = init_query
    @data_cube = []
  end

  def latest_week
    raise "Called abstract method: latest_week"
  end

  def latest_month
    raise "Called abstract method: latest_month"
  end

  def latest_quarter
    raise "Called abstract method: latest_quarter"
  end

  def latest_year
    raise "Called abstract method: latest_year"
  end

  def generate(periods, segments, states)
    raise "Called abstract method: generate"
  end

  def init_query
    { 'prod_serv' => @query }
  end
end


class BookingDataReport < Report

  attr_reader :latest_year

  def initialize(host, port, dbname)
    @collname = 'booking_dump'
    super(host, port, dbname, @collname)
    @proj_qry = { '$project' => { '_id' => 0} }
  end

  def latest_year
    return @latest_year if defined? @latest_year
    mtch_qry = {}
    grp_qry  = { '_id' => nil, 'max' => { '$max' => '$fiscal_year_id' } }
    agg( [{ '$match' => mtch_qry }, { '$group' => grp_qry }, { '$project' => @proj_qry } ]) do |doc|
      @latest_year = doc['max'].to_s
    end
    @latest_year
  end

  def latest_week
    return @latest_week if defined? @latest_week
    mtch_qry = { 'fiscal_year_id' => latest_year }
    grp_qry  = { '_id' => nil, 'max' => { '$max' => '$fiscal_week_id' } }
    agg( [{ '$match' => mtch_qry }, { '$group' => grp_qry }, { '$project' => @proj_qry } ]) do |doc|
      @latest_week = doc['max'].to_s
    end
    @latest_week
  end

  def latest_month
    return @latest_month if defined? @latest_month
    mtch_qry = { 'fiscal_year_id' => latest_year }
    grp_qry  = { '_id' => nil, 'max' => { '$max' => '$fiscal_period_id' } }
    agg( [{ '$match' => mtch_qry }, { '$group' => grp_qry }, { '$project' => @proj_qry } ]) do |doc|
      @latest_month = doc['max'].to_s
    end
    @latest_month
  end

  def latest_quarter
    return @latest_quarter if defined? @latest_quarter
    mtch_qry = { 'fiscal_year_id' => latest_year }
    grp_qry  = { '_id' => nil, 'max' => { '$max' => '$fiscal_quarter_id' } }
    agg( [{ '$match' => mtch_qry }, { '$group' => grp_qry }, { '$project' => @proj_qry } ]) do |doc|
      @latest_quarter = doc['max']
    end
    @latest_month
  end

  def generate(periods, segments, states, query, field)
    @query = query
    puts "Evaluating..."
    periods.each do |p|
      @query[field] = p.to_i
      segments.each do |g|
        @query['segment'] = g
        states.each do |s|
          @query['state'] = s
        end
      end
    end
    puts "\n\nAll done!"
  end

  private
  def set_metric_credentials(query, mongo_opts, period, segment, state)
    set_products_credentials(query, mongo_opts, period, segment, state)
    set_services_credentials(query, mongo_opts, period, segment, state)
    set_ro_credentials(query, mongo_opts, period, segment, state)
    set_security_credentials(query, mongo_opts, period, segment, state)
    set_access_switching_credentials(query, mongo_opts, period, segment, state)
    set_newpaper_credentials(query, mongo_opts, period, segment, state)
    set_pos_credentials(query, mongo_opts, period, segment, state)
    set_dcv_credentials(query, mongo_opts, period, segment, state)
    set_entnw_credentials(query, mongo_opts, period, segment, state)
    set_collab_credentials(query, mongo_opts, period, segment, state)
  end

  def set_products_credentials(query, mongo_opts, period, segment, state)
    bd = ProductsDataStruct.new(query, mongo_opts)
    @data_cube << { products: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_services_credentials(query, mongo_opts, period, segment, state)
    bd = ServicesDataStruct.new(query, mongo_opts)
    @data_cube << { services: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_ro_credentials(query, mongo_opts, period, segment, state)
    bd = RecurringOfferDataStruct.new(query, mongo_opts)
    @data_cube << { ro: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_security_credentials(query, mongo_opts, period, segment, state)
    bd = SecurityDataStruct.new(query, mongo_opts)
    @data_cube << { security: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_access_switching_credentials(query, mongo_opts, period, segment, state)
    bd = AccessSwitchingDataStruct.new(query, mongo_opts)
    @data_cube << { access_switching: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_newpaper_credentials(query, mongo_opts, period, segment, state)
    bd = NewPaperDataStruct.new(query, mongo_opts)
    @data_cube << { newpaper: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_pos_credentials(query, mongo_opts, period, segment, state)
    bd = POSDataStruct.new(query, mongo_opts)
    @data_cube << { pos: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_dcv_credentials(query, mongo_opts, period, segment, state)
    bd = DCVDataStruct.new(query, mongo_opts)
    @data_cube << { dcv: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_entnw_credentials(query, mongo_opts, period, segment, state)
    bd = EntNetWorkingDataStruct.new(query, mongo_opts)
    @data_cube << { entnw: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end

  def set_collab_credentials(query, mongo_opts, period, segment, state)
    bd = CollabDataStruct.new(query, mongo_opts)
    @data_cube << { collab: { booking_net: bd.booking_net, discount: bd.avg_discount } }
  end
end


class SFDCDataReport < Report

  def initialize(host, port, dbname)
    @collname = 'sfdc_dump'
    super(host, port, dbname, @collname)
  end

  def generate(periods, segments, states)
  end
end


class PlanDataReport < Report

  def initialize(host, port, dbname)
    @collname = 'comm_plan'
    super(host, port, dbname, @collname)
  end

  def generate(periods, segments, states)
  end
end


class WTDReport

  attr_accessor :bd

  def initialize(years, node_field, node, segments, states, mongo_config)
    @years      = years
    @bd         = BookingDataReport.new(mongo_config[:host], mongo_config[:port], mongo_config[:dbname])
    @periods    = historical_periods
    @node_field = node_field
    @node       = node
    @segments   = segments
    @states     = states
    @query      = @bd.query.merge({ node_field => node })
    @field      = 'fiscal_week_id'
  end

  def historical_periods
    last3_of_latest = @bd.latest_week.to_s[-3,3]
    @years.collect { |y| "#{y}#{last3_of_latest}" }
  end

  def generate
    @bd.generate(@periods, @segments, @states, @query, @field)
  end

  def make_booking_report
  end

  def make_sfdc_report
  end

  def make_plan_report
  end
end

