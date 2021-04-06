require 'gruffle/workflow_states'
require 'gruffle/workflow_validation'

module Gruffle
  class Workflow
    extend WorkflowValidation
    extend WorkflowStates
  end
end