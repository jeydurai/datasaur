# mongodb utilities
#

module Queryable
  def match_objects periods
    qry = []
    qry << prepare_match_objects(periods)
    qry << prepare_match_objects(@node_config)
    qry << prepare_match_objects(@prodserv_config)
    { '$match' => { '$and' => qry.flatten }}
  end

  def group_objects
    qry = group_uniquefields_object(@uniq_fields).merge(group_valuefields_object(@val_fields))
    { '$group' => qry }
  end

  def project_objects
    qry = { '_id' => 0 }
    qry.merge!(project_uniquefields_object(@uniq_fields))
    qry.merge!(project_valuefields_object(@val_fields))
    { '$project' => qry }
  end

  def project_uniquefields_object uniq_fields
    qry = {}
    uniq_fields.each do |field|
      qry.merge!({ field => "$_id.#{field}" })
    end
    qry
  end

  def project_valuefields_object val_fields
    qry = {}
    val_fields.each_key do |field|
      qry.merge!({ field => "$#{field}" })
    end
    qry
  end

  def group_uniquefields_object uniq_fields
    qry = {}
    uniq_fields.each do |field|
      qry.merge!({ field => "$#{field}" })
    end
    { '_id' => qry }
  end

  def group_valuefields_object val_fields
    qry = {}
    val_fields.each do |field, method|
      qry.merge!({ field => { agg_method(method) => "$#{field}" }})
    end
    qry
  end

  def agg_method method
    case method
    when :sum
      '$sum'
    when :avg
      '$avg'
    else
    end
  end

  def prepare_match_objects field_configs
    return {} if field_configs.empty?
    and_object = []
    field_configs.each do |field, configs|
      configs.each do |config|
        config.each do |method, vals|
          and_object << make_OR_object(method, vals, field)
        end
      end
    end
    and_object
  end

  def make_OR_object method, vals, field
    obj_container = []
    return makeobject(method, vals.first, field) if vals.length == 1
    vals.each do |val|
      obj_container << makeobject(method, val, field)
    end
    { '$or' => obj_container }
  end

  def makeobject method, val, field
    obj = case method
          when :eq
            { field => val}
          when :contains
            { field => /#{val}/}
          when :beginswith
            { field => /^#{val}/}
          when :endswith
            { field => /#{val}$/}
          else
            {}
          end
    obj
  end

  private :makeobject, :make_OR_object, :prepare_match_objects, :agg_method, :group_valuefields_object, :group_uniquefields_object, 
    :project_valuefields_object, :project_uniquefields_object
  public :match_objects, :group_objects, :project_objects
end


class QueryEngine
  include Queryable
  include Configurator::BusinessNodes::Configurable
  include Configurator::Fields::Configurable

  attr_accessor :node_field, :nodes, :uniq_fields, :val_fields, :node_config, :headers, :queries

  def initialize hist, fields_config
    @hist               = hist
    @cur_year           = 2018
    @node_field         = nil
    @nodes              = []
    @fields_config      = fields_config
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  def set_configurations
    @years           = make_years
    @finmonths       = make_finmonths
    @node_config     = make_node_config
    @prodserv_config = make_prodserv_config
    @uniq_fields     = select_uniq_fields
    @val_fields      = select_val_fields
    @headers         = make_one_uniq_fields
  end

  def redefine_fields
    remove_fields
    add_fields
    @headers = make_one_uniq_fields
  end

  def make_query
    qry = []
    @finmonths.each do |m|
      period_config = make_period_config m
      match         = match_objects period_config
      grp           = group_objects
      proj          = project_objects
      qry << [ match, grp, proj ]
    end
    qry
  end

  private :select_uniq_fields, :select_val_fields, :make_years, :make_finmonths, :make_period_config, :make_node_config, 
    :make_one_uniq_fields 
  public :remove_fields, :add_fields, :configure, :set_configurations, :redefine_fields
end


class BookingQueryEngine < QueryEngine

  def initialize hist, prodserv, fields_config
    super(hist, fields_config)
    @prodserv = prodserv
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  public :configure, :set_configurations
end


class SFDCQueryEngine < QueryEngine

  def initialize hist, prodserv, fields_config
    super(hist, fields_config)
    @prodserv = prodserv
  end

  def configure
    set_configurations
    redefine_fields
    @queries = make_query
  end

  def make_query
    match_objects({})
  end

  def select_uniq_fields
    [
      'fiscal_year_id', 'fiscal_quarter_id', 'fiscal_month_id', 'fiscal_week_id',
      'sales_level_4', 'sales_level_5', 'sales_level_6', 'sales_agent', 'rm_name', 'od_name',
      'segment', 'country', 'region', 'state', 'prod_serv', 'recurring_offer_flag', 'tier_code', 
      'grp_ver', 'grp_ver2', 'product_classification', 'arch1', 'arch2', 'tech_name1', 'tech_name2'
    ]
  end

  def select_val_fields
    { 'booking_net' => :sum, 'base_list' => :sum, 'standard_cost' => :sum }
  end

  public :configure, :set_configurations
end


