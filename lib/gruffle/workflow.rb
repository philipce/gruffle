require 'gruffle/workflow_states'
require 'gruffle/workflow_transitions'
require 'gruffle/workflow_validation'

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
    end

    extend WorkflowStates
    extend WorkflowTransitions
    extend WorkflowValidation
  end
end