require 'gruffle/workflow_states'
require 'gruffle/workflow_transitions'
require 'gruffle/workflow_validation'

module Gruffle
  class Workflow
    extend WorkflowStates
    extend WorkflowTransitions
    extend WorkflowValidation

    # TODO: is it possible to define/setup @states and @transitions here, instead of in the mixins?
    # The mixins need to share variables. It works fine to just reference them, but it's a bit hard to follow where
    # those variables are coming from. If they were in this class at least it'd be a bit clearer. Also, need to revisit
    # why the "ensure setup" type methods are needed. The class body should be executed on load so I'm not sure why just
    # declaring the class variables in the body doesn't seem to work.
  end
end