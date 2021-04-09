require 'gruffle/workflow_states'
require 'gruffle/workflow_transitions'
require 'gruffle/workflow_validation'

module Gruffle
  class Workflow
    extend WorkflowStates
    extend WorkflowTransitions
    extend WorkflowValidation
  end
end