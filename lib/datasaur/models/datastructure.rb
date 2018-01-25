
## Data Structure class
# ======================
class DataStruct < MongoBase
  include Queryable
  include Writeable

  attr_accessor :name, :parent, :query

  def initialize(name, mong_opts, model)
    super(mong_opts[:host], mong_opts[:port], mong_opts[:dbname], mong_opts[:collname])
    @name        = name
    @model       = model
    @uniq_fields = nil
    @val_fields  = set_val_fields
    @match_obj   = nil
    @query       = nil
    @data        = nil
    @parent      = nil
  end

  private
  def set_val_fields
    case @model
    when :booking
      @val_fields  = { 'booking_net' => :sum, 'base_list' => :sum, 'standard_cost' => :sum }
    when :pipe
      @val_fields  = { 'opportunity_line_value' => :sum }
    when :plan
      @val_fields  = { 'plan_year' => :sum, 'plan_q1' => :sum, 'plan_q2' => :sum, 'plan_q3' => :sum, 'plan_q4' => :sum }
    end
  end

  public
  # Returns the booking_net value from the instance variable data
  def booking_net
    @data['booking_net']
  end

  # Returns the base_list value from the instance variable data
  def base_list
    @data['base_list']
  end

  # Returns the standard_cost value from the instance variable data
  def standard_cost
    @data['standard_cost']
  end

  # Calculates using booking_net & base_list values and returns
  def avg_discount
    return 0.0 if base_list <= 0.0
    1-(booking_net.to_f/base_list.to_f)
  end

  # Calculates using booking_net & standard_cost values and returns
  def standard_margin
    return 0.0 if booking_net <= 0.0
    1-(standard_cost.to_f/booking_net.to_f)
  end

  # Returns the opportunity_line_value from the instance variable data
  def line_value
    @data['opportunity_line_value']
  end

  # Returns the plan for the year from the instance variable data
  def year_plan
    @data['plan_year']
  end

  # Returns the plan for Q1 from the instance variable data
  def q1_plan
    @data['plan_q1']
  end

  # Returns the plan for Q2 from the instance variable data
  def q2_plan
    @data['plan_q2']
  end

  # Returns the plan for Q3 from the instance variable data
  def q3_plan
    @data['plan_q3']
  end

  # Returns the plan for Q4 from the instance variable data
  def q4_plan
    @data['plan_q4']
  end

  # Returns the plan for H1 from the instance variable data
  def h1_plan
    q1_plan + q2_plan
  end

  # Returns the plan for H2 from the instance variable data
  def h2_plan
    q3_plan + q4_plan
  end

  # Returns the total number of data structure in sub structures
  def total_no_of_structs
    1
  end
  
  # Runs the MongoDB aggregate method through agg method in MongoBase module
  def get_aggregated
    agg(@query) do |doc|
      @data = {
        'booking_net'   => doc['booking_net'],
        'base_list'     => doc['base_list'],
        'standard_cost' => doc['standard_cost'],
      }
    end
  end

  # Overrides the Queryable module method and returns the aggregate match pipe object
  def match_objects
    { '$match' => @match_obj }
  end

  # Overrides the Queryable module method and returns the MongoDB aggregation query pipe
  def make_query
    match = match_objects
    grp   = group_objects
    proj  = project_objects
    [ match, grp, proj ]
  end

end


## Composite Data Structure class that inherits from DataStruct class
# ===================================================================
class CompositeDataStruct < DataStruct
  def initialize(name, mong_opts, model)
    super(name, mong_opts, model)
    @sub_structs = []
  end

  # Registers the sub structure into the instance variable @sub_structs
  def add_sub_struct(struct)
    @sub_structs << struct
    struct.parent = self
  end

  # Unregisters the sub structure into the instance variable @sub_structs
  def remove_sub_struct(struct)
    @sub_structs.delete(struct)
    struct.parent = nil
  end

  # Overrides the super class method and calculates booking_net by adding individual sub_strcuts' booking_net
  def booking_net
    return @booking_net if defined? @booking_net
    booking_net = 0.0
    @sub_structs.each { |struct| booking_net += struct.booking_net }
    @booking_net = booking_net
  end

  # Overrides the super class method and calculates base_list by adding individual sub_strcuts' base_list
  def base_list
    return @base_list if defined? @base_list
    base_list = 0.0
    @sub_structs.each { |struct| base_list += struct.base_list }
    @base_list = base_list
  end

  # Overrides the super class method and calculates standard_cost by adding individual sub_strcuts' standard_cost
  def standard_cost
    return @standard_cost if defined? @standard_cost
    standard_cost = 0.0
    @sub_structs.each { |struct| standard_cost += struct.standard_cost }
    @standard_cost = standard_cost
  end

  # Returns the opportunity_line_value from the instance variable data
  def line_value
    return @line_value if defined? @line_value
    line_value = 0.0
    @sub_structs.each { |struct| line_value += struct.line_value }
    @line_value = line_value
  end

  # Returns the plan for the year from the instance variable data
  def year_plan
    return @year_plan if defined? @year_plan
    year_plan = 0.0
    @sub_structs.each { |struct| year_plan += struct.year_plan }
    @year_plan = year_plan
  end

  # Returns the plan for Q1 from the instance variable data
  def q1_plan
    return @q1_plan if defined? @q1_plan
    q1_plan = 0.0
    @sub_structs.each { |struct| q1_plan += struct.q1_plan }
    @q1_plan = q1_plan
  end

  # Returns the plan for Q2 from the instance variable data
  def q2_plan
    return @q2_plan if defined? @q2_plan
    q2_plan = 0.0
    @sub_structs.each { |struct| q2_plan += struct.q2_plan }
    @q2_plan = q2_plan
  end

  # Returns the plan for Q3 from the instance variable data
  def q3_plan
    return @q3_plan if defined? @q3_plan
    q3_plan = 0.0
    @sub_structs.each { |struct| q3_plan += struct.q3_plan }
    @q3_plan = q3_plan
  end

  # Returns the plan for Q4 from the instance variable data
  def q4_plan
    return @q4_plan if defined? @q4_plan
    q4_plan = 0.0
    @sub_structs.each { |struct| q4_plan += struct.q4_plan }
    @q4_plan = q4_plan
  end

  # Returns the plan for H1 from the instance variable data
  def h1_plan
    return @h1_plan if defined? @h1_plan
    h1_plan = 0.0
    @sub_structs.each { |struct| h1_plan += struct.h1_plan }
    @h1_plan = h1_plan
  end

  # Returns the plan for H2 from the instance variable data
  def h2_plan
    return @h2_plan if defined? @h2_plan
    h2_plan = 0.0
    @sub_structs.each { |struct| h2_plan += struct.h2_plan }
    @h2_plan = h2_plan
  end

  # Overrides the super class method and calculates total number of structs by adding individual counts
  def total_no_of_structs
    return @total_no_of_structs if defined? @total_no_of_structs
    total = 0
    @sub_structs.each { |struct| total += struct.total_no_of_structs }
    @total_no_of_structs = total
  end
end


## Composite Data Structure class for calculating Total Products' architecture
# ============================================================================
class TotalProductArchsBookingDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('Total Booking', mong_opts, model)
    add_sub_struct EntNetWorkingDataStruct.new(query, mong_opts, model)
    add_sub_struct SecurityDataStruct.new(query, mong_opts, model)
    add_sub_struct CollabDataStruct.new(query, mong_opts, model)
    add_sub_struct DCVDataStruct.new(query, mong_opts, model)
    add_sub_struct OthersProducrtDataStruct.new(query, mong_opts, model)
  end
end


## Composite Data Structure class for calculating Total Services' architecture
# ============================================================================
class TotalServiceArchsBookingDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('Total Booking', mong_opts, model)
    add_sub_struct AdvancedServicesDataStruct.new(query, mong_opts, model)
    add_sub_struct TechnicalServicesDataStruct.new(query, mong_opts, model)
    add_sub_struct TrainingSercicesDataStruct.new(query, mong_opts, model)
  end
end


## Composite Data Structure class for calculating Enterprise Networking Data structure
# ====================================================================================
class EntNetWorkingDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('Enterprise Networking', mong_opts, model)
    add_sub_struct AccessSwitchingDataStruct.new(query, mong_opts, model)
    add_sub_struct LANSwitchingDataStruct.new(query, mong_opts, model)
    add_sub_struct RoutingDataStruct.new(query, mong_opts, model)
    add_sub_struct WirelessDataStruct.new(query, mong_opts, model)
    add_sub_struct MerakiDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating EN technology 'Meraki' Data structure
# ============================================================================
class MerakiDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Meraki', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Meraki' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating EN technology 'Wireless LAN' Data structure
# =================================================================================
class WirelessDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Wireless LAN', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Wireless LAN' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating EN technology 'Routing' Data structure
# ============================================================================
class RoutingDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Routing', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Routing' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating EN technology 'LAN Switching' Data structure
# ==================================================================================
class LANSwitchingDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('LAN Switching', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'LAN/SBTG Switching' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating EN technology 'Access Switching' Data structure
# =====================================================================================
class AccessSwitchingDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Access Switching', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Access Switching' })
    @query     = make_query
    get_aggregated
  end
end


## Composite Data Structure class for calculating architecture 'Security' Data structure
# ======================================================================================
class SecurityDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('Security', mong_opts, model)
    add_sub_struct NetworkSecurityDataStruct.new(query, mong_opts, model)
    add_sub_struct ContentSecurityDataStruct.new(query, mong_opts, model)
    add_sub_struct AdvancedThreatSecurityDataStruct.new(query, mong_opts, model)
    add_sub_struct PolicyAccessSecurityDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating Security technology 'Policy Access' Data structure
# ========================================================================================
class PolicyAccessSecurityDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Policy Access Security', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Policy Access' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Security technology 'Advanced Threat' Data structure
# ==========================================================================================
class AdvancedThreatSecurityDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Advanced Threat Security', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Advanced Threat' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Security technology 'Content (Email & Web)' Data structure
# ================================================================================================
class ContentSecurityDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Content Security', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Content (Email & Web)' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Security technology 'Network (MSR & NGF)' Data structure
# ==============================================================================================
class NetworkSecurityDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Network Security', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Network (MSR & NGF)' })
    @query     = make_query
    get_aggregated
  end
end


## Composite Data Structure class for calculating architecture 'Collaboration' Data structure
# ===========================================================================================
class CollabDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('Collaboration', mong_opts, model)
    add_sub_struct ConferencingDataStruct.new(query, mong_opts, model)
    add_sub_struct ContactCenterDataStruct.new(query, mong_opts, model)
    add_sub_struct TPEndpointsDataStruct.new(query, mong_opts, model)
    add_sub_struct TPInfrastructureDataStruct.new(query, mong_opts, model)
    add_sub_struct UCEndpointsDataStruct.new(query, mong_opts, model)
    add_sub_struct UCInfrastructureDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating Collab technology 'UC Infrastructure' Data structure
# ==========================================================================================
class UCInfrastructureDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('UC Infrastructure', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'UC Infrastructure' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Collab technology 'UC Endpoints' Data structure
# =====================================================================================
class UCEndpointsDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('UC Endpoints', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'UC Endpoints' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Collab technology 'TP Infrastructure' Data structure
# ==========================================================================================
class TPInfrastructureDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('TP Infrastructure', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'TP Infrastructure' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Collab technology 'TP Endpoints' Data structure
# =====================================================================================
class TPEndpointsDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('TP Endpoints', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'TP Endpoints' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Collab technology 'Contact Center' Data structure
# =======================================================================================
class ContactCenterDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Contact Center', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Contact Center' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Collab technology 'Conferencing' Data structure
# =====================================================================================
class ConferencingDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Conferencing', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Conferencing' })
    @query     = make_query
    get_aggregated
  end
end


## Composite Data Structure class for calculating architecture 'Data Centre & Virtualization' Data structure
# ==========================================================================================================
class DCVDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('Data Centre & Virtualization', mong_opts, model)
    add_sub_struct DCSwitchingDataStruct.new(query, mong_opts, model)
    add_sub_struct HyperConvergedDataStruct.new(query, mong_opts, model)
    add_sub_struct UCSDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating DCV technology 'UCS/Server' Data structure
# ================================================================================
class UCSDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('UCS', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'UCS' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating DCV technology 'Hyper Converged' Data structure
# =====================================================================================
class HyperConvergedDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Hyper Converged', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Hyper Converged' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating DCV technology 'DC Switching' Data structure
# ==================================================================================
class DCSwitchingDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('DC Switching', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'DC Switching' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating architecture 'Others-Product' Data structure
# ==================================================================================
class OthersProducrtDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Others-Product', mong_opts, model)
    @match_obj = qry.merge({ 'tech_name3' => 'Others-Product' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating 'Services' Data structure
# ===============================================================
class ServicesDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Services', mong_opts, model)
    @match_obj = qry.merge({ 'prod_serv' => 'services' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating 'Services' architecture 'Advanced Services' Data structure
# ================================================================================================
class AdvancedServicesDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Advanced Services', mong_opts, model)
    @match_obj = qry.merge({ 'arch2' => 'Advanced Services' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating 'Services' architecture 'Technical Services' Data structure
# =================================================================================================
class TechnicalServicesDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Technical Services', mong_opts, model)
    @match_obj = qry.merge({ 'arch2' => 'Technical Services' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating 'Services' architecture 'Training Services' Data structure
# ================================================================================================
class TrainingSercicesDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Training Services', mong_opts, model)
    @match_obj = qry.merge({ 'arch2' => 'Training Services' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating 'Products' Data structure
# ===============================================================
class ProductsDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Products', mong_opts, model)
    @match_obj = qry.merge({ 'prod_serv' => 'products' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating 'Recurring Offer' Data structure
# ======================================================================
class RecurringOfferDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Recurring Offer', mong_opts, model)
    @match_obj = qry.merge({ 'recurring_offer_flag' => 'Y' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Tier_Code 'New Paper' Data structure
# ==========================================================================
class NewPaperDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('New Paper', mong_opts, model)
    @match_obj = qry.merge({ 'tier_code' => 'New Paper' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating Tier_Code 'POS' Data structure
# ====================================================================
class POSDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('POS', mong_opts, model)
    @match_obj = qry.merge({ 'tier_code' => 'POS' })
    @query     = make_query
    get_aggregated
  end
end


## Composite Data Structure class for calculating region 'South' Data structure
# =============================================================================
class SouthDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('South', mong_opts, model)
    add_sub_struct AndhraPradeshDataStruct.new(query, mong_opts, model)
    add_sub_struct KarnatakaDataStruct.new(query, mong_opts, model)
    add_sub_struct KeralaDataStruct.new(query, mong_opts, model)
    add_sub_struct TamilNaduDataStruct.new(query, mong_opts, model)
    add_sub_struct SriLankaDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating State 'Andhra Pradesh' Data structure
# ===========================================================================
class AndhraPradeshDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Andhra Pradesh', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Andhra Pradesh/Telangana' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Telangana' Data structure
# ======================================================================
class TelanganaDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Telangana', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Andhra Pradesh/Telangana' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Karnataka' Data structure
# ======================================================================
class KarnatakaDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Karnataka', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Karnataka' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Kerala' Data structure
# ===================================================================
class KeralaDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Kerala', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Kerala' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Tamil Nadu' Data structure
# =======================================================================
class TamilNaduDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Tamil Nadu', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Tamil Nadu' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Sri Lanka' Data structure
# ======================================================================
class SriLankaDataStruct< DataStruct
  def initialize(qry, mong_opts, model)
    super('Sri Lanka', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Sri Lanka' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating region 'West' Data structure
# ==================================================================
class WestDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('South', mong_opts, model)
    add_sub_struct MaharashtraDataStruct.new(query, mong_opts, model)
    add_sub_struct RestOfMaharashtraDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating State 'Maharashtra' Data structure
# ========================================================================
class MaharashtraDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Maharashtra', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Maharashtra' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Rest of Maharashtra' Data structure
# ================================================================================
class RestOfMaharashtraDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Rest of Maharashtra', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Rest of Maharashtra' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating region 'North' Data structure
# ===================================================================
class NorthDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('North', mong_opts, model)
    add_sub_struct NCRDataStruct.new(query, mong_opts, model)
    add_sub_struct UPCDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating State 'NCR' Data structure
# ================================================================
class NCRDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('NCR', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'NCR' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'UPC' Data structure
# ================================================================
class UPCDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('UPC', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'UPC' })
    @query     = make_query
    get_aggregated
  end
end


## Composite Data Structure class for calculating region 'East' Data structure
# ============================================================================
class EastDataStruct < CompositeDataStruct
  def initialize(query, mong_opts, model)
    super('East', mong_opts, model)
    @match_obj = query.merge({ 'region' => 'East' })
    add_sub_struct WestBengalDataStruct.new(query, mong_opts, model)
    add_sub_struct NepalBhutanDataStruct.new(query, mong_opts, model)
    add_sub_struct UPCDataStruct.new(@match_obj, mong_opts, model)
    add_sub_struct EastOthersDataStruct.new(query, mong_opts, model)
  end
end


## Data Structure class for calculating State 'West Bengal' Data structure
# ========================================================================
class WestBengalDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('West Bengal', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'West Bengal' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Nepal/Bhutan' Data structure
# =========================================================================
class NepalBhutanDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Nepal/Bhutan', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Nepal/Bhutan' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'East-Others' Data structure
# ========================================================================
class EastOthersDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('East - Others', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'East - Others' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Bangladesh' Data structure
# =======================================================================
class BangladeshDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Bangladesh', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'Bangladesh' })
    @query     = make_query
    get_aggregated
  end
end


## Data Structure class for calculating State 'Misc' Data structure
# =================================================================
class MiscDataStruct < DataStruct
  def initialize(qry, mong_opts, model)
    super('Misc', mong_opts, model)
    @match_obj = qry.merge({ 'state' => 'MISC' })
    @query     = make_query
    get_aggregated
  end
end







