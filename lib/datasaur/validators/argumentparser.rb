# Module to contain command specific arguments parsers

module Parser
  module Generator
    module Parsable
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

      def parse_howis_args
        metric = ''; period = ''
        metrics = [ :tech_trending ]
        if @args.length == 2
          metric = Parsable.parse_metric(@args.first)
          period = Parsable.parse_period(@args.last)
        elsif @args.length == 1
          lastest_qtr = '2018Q2'
          metric = Parsable.parse_metric(@args.first)
          period = { 'fiscal_quarter_id' => lastest_qtr }
        else # else should be greater than 2
          metric = Parsable.parse_metric(@args.first)
          period = Parsable.parse_period(@args[0])
        end
        if metrics.include? metric
          return metric, period
        else
          return false, period
        end
      end

      def self.parse_metric arg
        parsed = arg.split(':')
        return parsed.first == 'in' ? parsed[1].to_sym : parsed.first.to_sym
      end

      def self.parse_period arg
        parsed = arg.split(':')
        case parsed.first.to_sym
        when :q
          { 'fiscal_quarter_id' => parsed[1] }
        when :h1
          { '$or': [{ 'fiscal_quarter_id' => "#{parsed[1]}Q1" }, { 'fiscal_quarter_id' => "#{parsed[1]}Q2" }]}
        when :h2
          { '$or': [{ 'fiscal_quarter_id' => "#{parsed[1]}Q3" }, { 'fiscal_quarter_id' => "#{parsed[1]}Q4" }]}
        else
          { 'fiscal_quarter_id' => parsed.first }
        end
      end
    end
  end
end
