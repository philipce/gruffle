require 'gruffle/workflow_states'
require 'gruffle/workflow_state_store'
require 'gruffle/workflow_transitions'
require 'gruffle/workflow_validation'
require 'gruffle/workflow_work_queue'

module Gruffle
  class Workflow
    extend WorkflowStates
    extend WorkflowStateStore
    extend WorkflowTransitions
    extend WorkflowValidation
    extend WorkflowWorkQueue

    def self.inherited(child_klass)
      child_klass.variables_setup
    end

    def self.variables_setup
      return if @variables_setup
      @variables_setup = true
      @states ||= {}
      @transitions ||= {}
      @work_queue = nil
      @state_store = nil
    end

    attr_reader :id

    def initialize(initial_payload: nil)
      @workflow_name = self.class.name
      @id = SecureRandom.uuid

      state_store_class = self.class.state_store[:adapter]
      state_store_config = self.class.state_store[:config]
      @state_store = state_store_class.new(*[state_store_config].compact)

      work_queue_class = self.class.work_queue[:adapter]
      work_queue_config = self.class.work_queue[:config]
      @work_queue = work_queue_class.new(*[work_queue_config].compact)

      if initial_payload
        klass = self.class.states(:initial).keys.first
        @initial_state = klass.new(workflow_name: @workflow_name, workflow_id: @id, payload: initial_payload)

        # TODO: consider whether state store and work queue need to be modified in a transaction
        # It seems like not, as long as the state store gets modified first. The state store is append only, so there's
        # no harm in adding to it, then having the work queue blow up and not get the work added; there'll just be an
        # orphan state hanging out there.
        @state_store.add(@initial_state)

        # TODO: reconsider this interface for adding to the work queue
        # Rather than directly adding, should it be a method that allows you to 'complete' a state? That way it can do
        # transactional stuff for other adapters, like adding successor states _as part_ of the completion? Maybe for an
        # initial state, a plain add is required? Or maybe there's a setup method that can only be called on empty work
        # queues or something like that, idk
        @work_queue.add(@initial_state.id)
      end
    end

    def name
      @workflow_name
    end

    # TODO: should this be here or in the inspector?
    # Seems like maybe it does belong here, but should be private? Any reason for this to be part of the public interface?
    # On the other hand, if it's here, what's the point of having the inspector at all?
    def initial_state
      initial_class = self.class.states(:initial).keys.first
      initial_states = @state_store.of_class(initial_class).values
      initial_states.find { |s| s.trace.empty? }
    end

    def next_state
      1
    end
  end
end