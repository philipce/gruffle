module WorkflowValidation
  def valid?
    validate[:valid]
  end

  def invalid?
    not valid?
  end

  def errors
    validate[:errors]
  end

  private

  VALIDATION_METHODS = [
    :at_least_one_state,
    :correct_state_inheritance,
    :correct_transition_inheritance,
  ]

  def validate
    results = VALIDATION_METHODS.map { |v| method(v).call }
    valid = results.reduce(true) { |bool, result| bool & result[:valid] }
    error_messages = results.each_with_object([]) do |result, array|
      array << result[:message] unless result[:valid]
    end.compact

    {
      valid: valid,
      errors: error_messages,
    }
  end

  def at_least_one_state
    # TODO: sort of a bummer to have an implicit dependency on WorkflowTransitions being mixed in with WorkflowStates
    valid = self.states.keys.count >= 1
    message = 'Workflow must declare at least one state' unless valid

    {valid: valid, message: message}
  end

  def correct_state_inheritance
    # TODO: sort of a bummer to have an implicit dependency on WorkflowTransitions being mixed in with WorkflowStates
    valid = self.states.keys.all? { |s| s < Gruffle::State }
    message = 'Workflow states must inherit from Gruffle::State' unless valid

    {valid: valid, message: message}
  end

  def correct_transition_inheritance
    # TODO: sort of a bummer to have an implicit dependency on WorkflowTransitions being mixed in with WorkflowStates
    valid = self.transitions.all? { |s| s < Gruffle::Transition }
    message = 'Workflow states must inherit from Gruffle::Transition' unless valid

    {valid: valid, message: message}
  end

  # TODO: running list of validations to add:
  # - same state cannot be declared more than once (whether multiple times as same type or as different types)
  # - exactly one single initial state and one final state must be declared (what about workflows that have a single state? maybe for convenience, if only one state is declared, infer final and initial)
  # - all declared transitions must inherit from Gruffle::Transition
  # - source states must be declared before transitions
end