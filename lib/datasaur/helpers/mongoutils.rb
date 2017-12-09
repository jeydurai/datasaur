# mongodb utilities

module Queryable
  def match_objects periods, nodes, others: {}
    qry = []
    qry << prepare_match_objects(periods)
    qry << prepare_match_objects(nodes)
    qry << prepare_match_objects(others)
    { '$match' => { '$and' => qry.flatten }}
  end

  def group_objects uniq_fields, val_fields
    qry = group_uniquefields_object(uniq_fields).merge(group_valuefields_object(val_fields))
    { '$group' => qry }
  end

  def project_objects uniq_fields, val_fields
    qry = { '_id' => 0 }
    qry.merge!(project_uniquefields_object(uniq_fields))
    qry.merge!(project_valuefields_object(val_fields))
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

  attr_accessor :node_field, :nodes, :uniq_fields, :val_fields, :node_config, :headers

  def initialize hist, fields_config
    @hist          = hist
    @cur_year      = 2018
    @node_field    = nil
    @nodes         = []
    @fields_config = fields_config
  end

  def set_configurations
    @years         = make_years
    @finmonths     = make_finmonths
    @node_config   = make_node_config
    @uniq_fields   = select_uniq_fields
    @val_fields    = select_val_fields
    @headers       = make_one_uniq_fields
  end

  def redefine_fields
    remove_fields
    add_fields
    @headers = make_one_uniq_fields
  end

  def remove_fields
    fields = @fields_config[:discard]
    fields.each { |field| @uniq_fields.delete(field) if @uniq_fields.include? field }
    fields.each { |field| @val_fields.delete(field) if @val_fields.has_key? field }
  end

  def add_fields
    fields = @fields_config[:add]
    fields.each { |field| @uniq_fields << field unless @uniq_fields.include? field }
  end

  def make_one_uniq_fields
    fields = @uniq_fields.select { |f| f }
    @val_fields.each_key { |f| fields << f }
    fields
  end

  def make_query
    qry = []
    @finmonths.each do |m|
      period_config = make_period_config m
      match         = match_objects period_config, @node_config
      grp           = group_objects @uniq_fields, @val_fields
      proj          = project_objects @uniq_fields, @val_fields
      qry << [ match, grp, proj ]
    end
    qry
  end

  def make_node_config
    { @node_field => [ { eq: @nodes } ] }
  end

  def make_period_config finmonth
    { 'fiscal_period_id' => [ { eq: [ finmonth ] } ] }
  end

  def make_finmonths
    finmonths = []
    months = 1.upto(12).select { |m| m }
    @years.each do |y|
      months.each do |m|
        finmonths << "#{y.to_s}#{m.to_s.rjust(2, '0')}".to_i
      end
    end
    finmonths
  end

  def make_years
    years = []
    @cur_year.downto(@cur_year-(@hist-1)) do |y|
      years << y
    end
    years
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

  private :select_uniq_fields, :select_val_fields, :make_years, :make_finmonths, :make_period_config, :make_node_config, 
    :make_one_uniq_fields, :redefine_fields
  public :make_query, :set_configurations, :remove_fields, :add_fields
end

