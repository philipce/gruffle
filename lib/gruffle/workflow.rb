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

    attr_reader :initial_state
    attr_reader :id

    def initialize(payload)
      klass = self.class.states(:initial).keys.first
      workflow_name = self.class.name
      @id = SecureRandom.uuid
      @initial_state = klass.new(workflow_name: workflow_name, workflow_id: @id, payload: payload)

      # TODO: consider whether state store and work queue need to be modified in a transaction
      # It seems like not, as long as the state store gets modified first. The state store is append only, so there's
      # no harm in adding to it, then having the work queue blow up and not get the work added; there'll just be an
      # orphan state hanging out there.
      self.class.state_store.add(@initial_state)

      # TODO: reconsider this interface for adding to the work queue
      # Rather than directly adding, should it be a method that allows you to 'complete' a state? That way it can do
      # transactional stuff for other adapters, like adding successor states _as part_ of the completion? Maybe for an
      # initial state, a plain add is required? Or maybe there's a setup method that can only be called on empty work
      # queues or something like that, idk
      self.class.work_queue.add(@initial_state.id)
    end
  end
end