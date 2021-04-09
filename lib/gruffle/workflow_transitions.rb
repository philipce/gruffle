module WorkflowTransitions
  def transition(from:, via:)
    # TODO: allow other options when declaring transition
    # - when (condition)
    # - error (error state)

    # TODO: revisit signature
    # Maybe via: shouldn't be a named param; maybe the signature should be `transition(klass, from:, when:, error:)`.
    # It reads kinda nicely to have via, but `transition FooTransition, from: BarState` is more consistent with state
    # declaration signature

    state_klass = from
    transition_klass = via

    ensure_transition_setup

    @transitions[state_klass] = transition_klass

    # TODO: is there a meaningful return type here?
    # True if it was declared, false if not? Seems like that might be overreaching and best left to validation
    nil
  end

  def transitions(*from)
    # TODO: sort of a bummer to have an implicit dependency on WorkflowTransitions being mixed in with WorkflowStates
    from = self.states.keys if from.empty?
    @transitions.slice(*from).values
  end

  private

  def ensure_transition_setup
    @transitions ||= {}
  end
end