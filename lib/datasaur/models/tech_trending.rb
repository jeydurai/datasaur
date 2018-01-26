# tech_trending.rb


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
    xl = ExcelIO.new(@owner)
    @dispatcher.each do |d|
      xl.write_cell(d)
    end
    puts "[Process]: Saving Data..."
    xl.save
  end

  def set_ENTNW_booking
    row_refs = (9 .. 13).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", AccessSwitchingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", LANSwitchingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", RoutingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", WirelessDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", MerakiDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_Security_booking
    row_refs = (15 .. 18).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", NetworkSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_ref[1]}", ContentSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", AdvancedThreatSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", PolicyAccessSecurityDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_Collab_booking
    row_refs = (20 .. 25).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", ConferencingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContactCenterDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", TPEndpointsDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", TPInfrastructureDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[4]}", UCEndpointsDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCInfrastructureDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_DCV_booking
    row_refs = (27 .. 29).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", DCSwitchingDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", HyperConvergedDataStruct.new(@qry, @mong_config, :booking).booking_net)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCSDataStruct.new(@qry, @mong_config, :booking).booking_net)
  end

  def set_Others_booking
    row_refs = [30]
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", OthersProducrtDataStruct.new(@qry, @mong_config, :booking).booking_net)
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
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.[1]}", HyperConvergedDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCSDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
  end

  def set_Others_pipe(col_ref)
    row_refs = [30]
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", OthersProducrtDataStruct.new(@itmt_qry, @mong_config, :pipe).line_value)
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
    puts "[Process]: Preparing Commit Data..."
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

  def set_ENTNW_plan(col_ref)
    row_refs = (9 .. 13).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", AccessSwitchingDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", LANSwitchingDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", RoutingDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", WirelessDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", MerakiDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
  end

  def set_Security_plan(col_ref)
    row_refs = (15 .. 18).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", NetworkSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContentSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", AdvancedThreatSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", PolicyAccessSecurityDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
  end

  def set_Collab_plan(col_ref)
    row_refs = (20 .. 25).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", ConferencingDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[1]}", ContactCenterDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[2]}", TPEndpointsDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[3]}", TPInfrastructureDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs[4]}", UCEndpointsDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCInfrastructureDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
  end

  def set_DCV_plan(col_ref)
    row_refs = (27 .. 29).collect { |i| i }
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", DCSwitchingDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.[1]}", HyperConvergedDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.last}", UCSDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
  end

  def set_Others_plan(col_ref)
    row_refs = [30]
    @dispatcher << CellConfig.new( "#{col_ref}#{row_refs.first}", OthersProducrtDataStruct.new(@itmt_qry, @mong_config, :pipe).plan)
  end

  def prepare_plan
    puts "[Process]: Preparing Plan Data..."
    @mong_config[:collname] = 'architecture_plan'
    @itmt_qry = @qry.merge({ 'plan_type' => 'stretch' })
    col_ref = 'D'
    set_ENTNW_plan col_ref
    set_Security_plan col_ref
    set_Collab_plan col_ref
    set_DCV_plan col_ref
    set_Others_plan col_ref
  end

end

