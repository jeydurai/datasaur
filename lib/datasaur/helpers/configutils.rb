# Module to hold configurable utitlities

module Configurator

  module Fields
    module Configurable
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
    end
  end 

  module BusinessNodes
    module Configurable

      def make_prodserv_config
        if @prodserv[:products] and @prodserv[:services]
          { 'prod_serv' => [ { eq: [ 'products', 'services' ]  } ]}
        elsif @prodserv[:products]
          { 'prod_serv' => [ { eq: [ 'products' ]  } ]}
        elsif @prodserv[:services]
          { 'prod_serv' => [ { eq: [ 'services' ]  } ]}
        else
          raise "[Runtime Error]: Prodserv options: both 'products' and 'services' are false!"
        end
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
    end
  end

  module Generator

    module Configurable

      def choose_model generator_type
        if generator_type == :booking
          choose_booking_model
        elsif generator_type == :sfdc
          choose_sfdc_model
        end
      end

      def choose_booking_model
        case @owner
        when :sudhir
          COMBookingDump.new(@hist, @prodserv, @fields_config)
        when :tm
          SLTLBookingDump.new(@hist, @prodserv, @fields_config)
        when :mukund
          SWGEOBookingDump.new(@hist, @prodserv, @fields_config)
        when :vipul
          NEGEOBookingDump.new(@hist, @prodserv, @fields_config)
        when :fakhrudhin
          BDBookingDump.new(@hist, @prodserv, @fields_config)
        when :rajeev
          SLTLSouthBookingDump.new(@hist, @prodserv, @fields_config)
        when :manoj
          SLTLWestBookingDump.new(@hist, @prodserv, @fields_config)
        else
          raise "[Runtime Error]: Owner unfound!"
        end
      end

      def choose_sfdc_model
        case @owner
        when :sudhir
          COMSFDCDump.new(@hist, @prodserv, @fields_config)
        when :tm
          SLTLSFDCDump.new(@hist, @prodserv, @fields_config)
        when :mukund
          SWGEOSFDCDump.new(@hist, @prodserv, @fields_config)
        when :vipul
          NEGEOSFDCDump.new(@hist, @prodserv, @fields_config)
        when :fakhrudhin
          BDSFDCDump.new(@hist, @prodserv, @fields_config)
        when :rajeev
          SLTLSouthSFDCDump.new(@hist, @prodserv, @fields_config)
        when :manoj
          SLTLWestSFDCDump.new(@hist, @prodserv, @fields_config)
        else
          raise "[Runtime Error]: Owner unfound!"
        end
      end

    end

  end
  
end
