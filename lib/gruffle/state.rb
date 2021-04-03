require 'securerandom'
require 'time'
require 'json'

module Gruffle
  class State
    attr_reader :workflow_name
    attr_reader :workflow_id
    attr_reader :name
    attr_reader :id
    attr_reader :trace
    attr_reader :fork_token
    attr_reader :join_tokens
    attr_reader :created_at
    attr_reader :payload

    def self.derive(original_state)
      # TODO: accept params to modify payload and attributes
      # For example: derive(original_state, payload: {}, attributes: {})
      # Need to decide what attributes are even modifiable; it may just be fork/join tokens
      # Also need to decide how payload works; does it accumulate by default? Or get replaced anew each derive? My first
      # thought is it should get wiped every time as it's probably the typical case we just care about new params. If
      # the user wants to accumulate params, that'd be easy to slice out and include in the new payload. If we went the
      # other route (always accumulate), we'd eventually blow up in memory potentially
      derived_payload = {}

      successor_state = new(workflow_name: original_state.workflow_name, payload: derived_payload)
      successor_state.instance_variable_set(:@workflow_id, original_state.workflow_id)

      # TODO: somehow derive will need to take a transition to add transition attributes to trace
      # Perhaps the user is never responsible for calling derive directly. The workflow engine could take a state and
      # the relevant transition, call transition(state), then expect the transition result to just contain subsequent
      # states. The engine could then call the derive function and pass in transition result details too. It would mean
      # the transition result would need to allow specifying payload/attribute updates
      new_trace = original_state.trace.deep_dup
      new_trace.push(state: original_state)
      successor_state.instance_variable_set(:@trace, new_trace)

      # TODO: derive needs to allow setting new fork/join tokens
      # Something like:
      #   derived_state.fork_token = derived_attributes[:fork_token].dup || state.fork_token
      #   derived_state.join_tokens = derived_attributes[:join_tokens].dup || []

      successor_state
    end

    def self.name
      super.split('::').last
    end

    def self.deserialize(json_string)
      hash = JSON.parse(json_string, symbolize_names: true)

      # TODO: add note to docs somewhere about how payload isn't parsed beyond native json types
      # - for example dates in payload will be strings, not Time objects. But integers will parse as ints.
      state = new(workflow_name: hash[:workflow_name], payload: hash[:payload])

      state.instance_variable_set(:@workflow_id, hash[:workflow_id])
      state.instance_variable_set(:@name, hash[:name])
      state.instance_variable_set(:@id, hash[:id])
      state.instance_variable_set(:@trace, Trace.from_hash(hash[:trace]))
      state.instance_variable_set(:@fork_token, hash[:fork_token])
      state.instance_variable_set(:@join_tokens, hash[:join_tokens])
      state.instance_variable_set(:@created_at, Time.parse(hash[:created_at]).utc)

      state
    end

    def initialize(workflow_name:, payload: nil)
      @workflow_name = workflow_name
      @workflow_id = SecureRandom.uuid
      @name = self.class.name
      @id = SecureRandom.uuid
      @trace = Trace.new
      @fork_token = nil
      @join_tokens = []
      @created_at = Time.now.utc
      @payload = (payload || Hash.new).transform_keys(&:to_sym)
    end

    def serialize
      {
        workflow_name: workflow_name,
        workflow_id: workflow_id,
        name: name,
        id: id,
        trace: trace,
        fork_token: fork_token,
        join_tokens: join_tokens,
        created_at: created_at.utc.iso8601,
        payload: payload,
      }.to_json
    end

    def ==(other_state)
      return false unless other_state
      return false unless self.class == other_state.class

      # Since state is immutable and ids are universally unique, id equality is sufficient to consider them equal
      self.id == other_state.id
    end

    def eql?(other_state)
      self == other_state
    end

    def hash
      self.id.hash
    end

  end
end
