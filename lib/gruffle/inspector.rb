require 'gruffle/workflow_states'

module Gruffle
  def Inspector(workflow_instance)
    Inspector.new(workflow_instance)
  end

  module_function :Inspector

  class Inspector
    def initialize(workflow_instance)
      @workflow_klass = workflow_instance.class
      @state_store = @workflow_klass.state_store
    end

    def states(*types)
      state_klasses = @workflow_klass.states(*types).keys
      @state_store.by_klass(state_klasses)
    end
  end
end