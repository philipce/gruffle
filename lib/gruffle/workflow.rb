require 'gruffle/workflow_states'
require 'gruffle/workflow_state_store'
require 'gruffle/workflow_transitions'
require 'gruffle/workflow_validation'
require 'gruffle/workflow_work_queue'

module Gruffle
  class Workflow
    def self.setup(initial_payload: {})
      workflow = self.new
      execution_id = SecureRandom.uuid
      initial_class = workflow.class.states(:initial).keys.first
      initial_state = initial_class.new(workflow_name: workflow.name, execution_id: execution_id, payload: initial_payload)

      # TODO: reconsider how the state store/work queue add methods should fail
      # Current assumption is they raise, but returning an error status instead could be a viable option

      # Adding to the state store and work queue don't need to happen in a transaction, so long as we never end up with
      # a state id in the work queue without a corresponding entry in the state store.
      workflow.send(:state_store).add(initial_state)
      workflow.send(:work_queue).add(initial_state.id)

      return workflow, execution_id
    end

    def name
      self.class.name
    end

    def initialize
      state_store_class = self.class.state_store[:adapter]
      state_store_config = self.class.state_store[:config]
      @state_store = state_store_class.new(*[state_store_config].compact)

      work_queue_class = self.class.work_queue[:adapter]
      work_queue_config = self.class.work_queue[:config]
      @work_queue = work_queue_class.new(*[work_queue_config].compact)
    end

    class << self
      private

      include WorkflowStates
      include WorkflowStateStore
      include WorkflowTransitions
      include WorkflowValidation
      include WorkflowWorkQueue

      def inherited(child_klass)
        child_klass.send(:variables_setup)
      end

      def variables_setup
        return if @variables_setup
        @variables_setup = true
        @states ||= {}
        @transitions ||= {}
        @work_queue = nil
        @state_store = nil
      end
    end

    private

    attr_reader :state_store
    attr_reader :work_queue

    def next_state
      # FIXME: all this needs to be made thread-safe and resilient!
      id = @work_queue.next
      @state_store.get(id)
    end
  end
end