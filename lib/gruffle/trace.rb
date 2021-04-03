require 'forwardable'

module Gruffle
  class Trace
    extend Forwardable
    def_delegators :@points, :empty?, :length, :[], :first, :last

    def self.from_hash(hash)
      trace = new
      hash[:points].each do |p|
        trace.instance_variable_get(:@points) << Point.from_hash(p)
      end

      trace
    end

    def initialize
      @points = []
    end

    def push(state:)
      point = Point.new(state: state)
      @points.push(point)
    end

    def to_json(options = {})
      {
        points: @points,
      }.to_json(options)
    end

    def deep_dup
      json_string = to_json
      hash = JSON.parse(json_string, symbolize_names: true)
      Trace.from_hash(hash)
    end

    def ==(other_trace)
      return false unless other_trace
      return false unless self.class == other_trace.class

      @points == other_trace.instance_variable_get(:@points)
    end

    def eql?(other_state)
      self == other_state
    end

    class Point
      attr_reader :state_name
      attr_reader :state_id
      attr_reader :state_created_at

      def self.from_hash(hash)
        state = OpenStruct.new(
          name: hash[:state_name],
          id: hash[:state_id],
          created_at: Time.parse(hash[:state_created_at]).utc,
        )

        new(state: state)
      end

      def initialize(state:)
        # TODO: take transition as well and store: transition_started_at, transition_finished_at, transition_status
        @state_name = state.name
        @state_id = state.id
        @state_created_at = state.created_at
      end

      def to_json(options = {})
        {
          state_name: @state_name,
          state_id: @state_id,
          state_created_at: @state_created_at.utc.iso8601,
        }.to_json(options)
      end

      def ==(other_point)
        return false unless other_point
        return false unless self.class == other_point.class

        @state_name == other_point.state_name
        @state_id == other_point.state_id
        @state_created_at == other_point.state_created_at
      end

      def eql?(other_state)
        self == other_state
      end
    end
  end
end