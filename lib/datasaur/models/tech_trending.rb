# tech_trending.rb

require 'awesome_print'

class TechTrending
  def initialize(mong_config, owner, period)
    @mong_config = mong_config
    @owner       = owner
    @period      = period
    @qry         = {}
    @itmt_qry    = {}
    @dispatcher  = []
  end

  def run
    set_query
    prepare_booking
    prepare_plan
    prepare_pipe
    write_all
  end

  private
  def set_query
    case @owner
    when :sudhir
      @qry = @period.merge({ 'sales_level_3' => 'INDIA_COMM_1' })
    else
    end
  end

  def write_all
    puts "[Process]: Writing Data..."
    xl = ExcelIO.new(@owner, sheetname: 'Entry')
    @dispatcher.each do |d|
      xl.write_cell(d)
    end
    puts "[Process]: Saving Data..."
    xl.save
  end

  def set_ENTNW_booking(col_ref)
    row_refs = (9 .. 13).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", AccessSwitchingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", LANSwitchingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", RoutingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", WirelessDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", MerakiDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_Security_booking(col_ref)
    row_refs = (15 .. 18).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", NetworkSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContentSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", AdvancedThreatSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", PolicyAccessSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_Collab_booking(col_ref)
    row_refs = (20 .. 25).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", ConferencingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContactCenterDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", TPEndpointsDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", TPInfrastructureDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[4]}", UCEndpointsDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCInfrastructureDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_DCV_booking(col_ref)
    row_refs = (27 .. 29).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", DCSwitchingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", HyperConvergedDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCSDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_Others_booking(col_ref)
    row_refs = [30]
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", OthersProductDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def prepare_booking
    puts "[Process]: Preparing Booking Data..."
    @mong_config[:collname] = 'booking_dump'
    col_ref = 'C'
    set_ENTNW_booking col_ref
    set_Security_booking col_ref
    set_Collab_booking col_ref
    set_DCV_booking col_ref
    set_Others_booking col_ref
  end

  def set_ENTNW_pipe(col_ref)
    row_refs = (9 .. 13).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", AccessSwitchingDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", LANSwitchingDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", RoutingDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", WirelessDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", MerakiDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
  end

  def set_Security_pipe(col_ref)
    row_refs = (15 .. 18).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", NetworkSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContentSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", AdvancedThreatSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", PolicyAccessSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
  end

  def set_Collab_pipe(col_ref)
    row_refs = (20 .. 25).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", ConferencingDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContactCenterDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", TPEndpointsDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", TPInfrastructureDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[4]}", UCEndpointsDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCInfrastructureDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
  end

  def set_DCV_pipe(col_ref)
    row_refs = (27 .. 29).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", DCSwitchingDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", HyperConvergedDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCSDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
  end

  def set_Others_pipe(col_ref)
    row_refs = [30]
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", OthersProductDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
  end

  def prepare_commit
    puts "[Process]: Preparing Commit Data..."
    @itmt_qry = @itmt_qry.merge({ 'forecast_status' => 'Commit' })
    col_ref = 'I'
    set_ENTNW_pipe col_ref
    set_Security_pipe col_ref
    set_Collab_pipe col_ref
    set_DCV_pipe col_ref
    set_Others_pipe col_ref
  end

  def prepare_upside
    puts "[Process]: Preparing Upside Data..."
    @itmt_qry = @itmt_qry.merge({ 'forecast_status' => 'Upside' })
    col_ref = 'J'
    set_ENTNW_pipe col_ref
    set_Security_pipe col_ref
    set_Collab_pipe col_ref
    set_DCV_pipe col_ref
    set_Others_pipe col_ref
  end

  def prepare_pipe
    @mong_config[:collname] = 'sfdc_dump'
    @itmt_qry = @qry.merge({ 'opportunity_status' => 'Active', 'past_due' => 'NEGATIVE' })
    prepare_commit
    prepare_upside
  end

  def set_ENTNW_plan(col_ref, total)
    calculator = ENTNWCalculator.new(@mong_config, total)
    row_refs = (9 .. 13).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", calculator.access_switch)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", calculator.lan_switch)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", calculator.routing)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", calculator.wireless)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", calculator.meraki)
  end

  def set_Security_plan(col_ref, total)
    calculator = SecurityCalculator.new(@mong_config, total)
    row_refs = (15 .. 18).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", calculator.network)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", calculator.content)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", calculator.advanced_threat)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", calculator.policy_access)
  end

  def set_Collab_plan(col_ref, total)
    calculator = CollabCalculator.new(@mong_config, total)
    row_refs = (20 .. 25).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", calculator.conferencing)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", calculator.contact_center)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", calculator.tp_endpoints)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", calculator.tp_infra)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[4]}", calculator.uc_endpoints)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", calculator.uc_infra)
  end

  def set_DCV_plan(col_ref, total)
    calculator = DCVCalculator.new(@mong_config, total)
    row_refs = (27 .. 29).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", calculator.dc_switch)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", calculator.hyper_converged)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", calculator.ucs)
  end

  def set_Others_plan(col_ref)
    @mong_config[:collname] = 'architecture_plan'
    row_refs = [30]
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", OthersProductDataStruct.new(@itmt_qry, @mong_config, :plan).plan)
  end

  def prepare_plan
    puts "[Process]: Preparing Plan Data..."
    @mong_config[:collname] = 'architecture_plan'
    @itmt_qry = @qry.merge({ 'plan_type' => 'stretch' })
    col_ref  = 'D'
    ent_nw   = ENTNWDataStruct.new(@itmt_qry, @mong_config, :plan).plan
    security = SECDataStruct.new(@itmt_qry, @mong_config, :plan).plan
    collab   = CollabDataStruct.new(@itmt_qry, @mong_config, :plan).plan
    dcv      = DCVDataStruct.new(@itmt_qry, @mong_config, :plan).plan
    @mong_config[:collname] = 'tech_plan_ratio'
    set_ENTNW_plan col_ref, ent_nw
    set_Security_plan col_ref, security
    set_Collab_plan col_ref, collab
    set_DCV_plan col_ref, dcv
    #set_Others_plan col_ref
  end

end


class TechnologyCalculator < MongoBase
  def initialize(mong_opts, total)
    super(mong_opts[:host], mong_opts[:port], mong_opts[:dbname], mong_opts[:collname])
    @total         = total
    @ratios        = {}
    set_ratios
  end

  def set_ratios
    find_doc({}) { |doc| @ratios[doc['arch_tech'].downcase] = doc['ratio'] }
  end
end


class ENTNWCalculator < TechnologyCalculator
  def initialize(mong_opts, total)
    super(mong_opts, total)
  end

  def access_switch
    @ratios['access switching'] * @total
  end

  def lan_switch
    @ratios['lan/sbtg switching'] * @total
  end

  def routing
    @ratios['routing'] * @total
  end

  def wireless
    @ratios['wireless lan'] * @total
  end

  def meraki
    @ratios['meraki'] * @total
  end
end


class SecurityCalculator < TechnologyCalculator
  def initialize(mong_opts, total)
    super(mong_opts, total)
  end

  def network
    @ratios['network (msr & ngf)'] * @total
  end

  def content
    @ratios['content (email & web)'] * @total
  end

  def advanced_threat
    @ratios['advanced threat'] * @total
  end

  def policy_access
    @ratios['policy access'] * @total
  end
end


class CollabCalculator < TechnologyCalculator
  def initialize(mong_opts, total)
    super(mong_opts, total)
  end

  def conferencing
    @ratios['conferencing'] * @total
  end

  def contact_center
    @ratios['contact center'] * @total
  end

  def tp_endpoints
    @ratios['tp endpoints'] * @total
  end

  def tp_infra
    @ratios['tp infrastructure'] * @total
  end

  def uc_endpoints
    @ratios['uc endpoints'] * @total
  end

  def uc_infra
    @ratios['uc infrastructure'] * @total
  end
end


class DCVCalculator < TechnologyCalculator
  def initialize(mong_opts, total)
    super(mong_opts, total)
  end

  def dc_switch
    @ratios['dc switching'] * @total
  end

  def hyper_converged
    @ratios['hyper converged'] * @total
  end

  def ucs
    @ratios['ucs'] * @total
  end
end



