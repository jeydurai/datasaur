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
    end
  end
end
