require 'gruffle/workflow_states'

module Gruffle
  class Inspector
    def initialize(workflow)
      @workflow, @workflow_class = initialize_workflow(workflow)
      @state_store = @workflow.send(:state_store)
    end

    # TODO: re think this method...
    # There's not generally just one initial state on a workflow. There'd be 1 per exeuction of that workflow. Should
    # the inspector have chainable methods that let you filter down to a particular execution, for example?
    def initial_state
      initial_class = @workflow_class.states(:initial).keys.first
      initial_states = @state_store.by_class(initial_class)
      initial_states.find { |s| s.trace.empty? }
    end

    def final_states
      final_classes = @workflow_class.states(:final).keys.first
      @state_store.by_class(*final_classes)
    end

    private

    def initialize_workflow(workflow)
      if workflow.is_a? Gruffle::Workflow
        return workflow, workflow.class
      elsif workflow.respond_to?(:<) && workflow < Gruffle::Workflow
        return workflow.new, workflow
      else
        raise "Unable to inspect workflow: #{workflow}"
      end
    end
  end
end