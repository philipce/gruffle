module WorkflowTransitions
  def transition(klass, source:)
    # TODO: allow other options when declaring transition
    # - condition:
    # - error:

    transition_klass = klass
    state_klass = source

    @transitions[state_klass] = transition_klass

    # TODO: is there a meaningful return type here?
    # True if it was declared, false if not? Seems like that might be overreaching and best left to validation
    nil
  end

  def transitions(*sources)
    sources = self.states.keys if sources.empty?
    @transitions.slice(*sources).values
  end
end