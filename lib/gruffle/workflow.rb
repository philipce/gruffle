require 'gruffle/workflow_states'
require 'gruffle/workflow_transitions'
require 'gruffle/workflow_validation'
require 'gruffle/workflow_work_queue'

module Gruffle
  class Workflow
    def self.inherited(child_klass)
      child_klass.variables_setup
    end

    def self.variables_setup
      return if @variables_setup
      @variables_setup = true
      @states ||= {}
      @transitions ||= {}
      @work_queue = nil
    end

    extend WorkflowStates
    extend WorkflowTransitions
    extend WorkflowValidation
    extend WorkflowWorkQueue
  end
end