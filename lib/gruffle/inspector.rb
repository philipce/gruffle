require 'gruffle/workflow_states'

module Gruffle
  class Inspector
    def initialize(workflow_instance) # TODO: take either instance or class
      @workflow_instance = workflow_instance
    end

    def states
      @workflow_instance.states
    end

    def initial_state
      @workflow_instance.initial_state
    end

  end
end