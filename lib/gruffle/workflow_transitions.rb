module WorkflowTransitions
  def transition(klass, source:)
    # TODO: allow other options when declaring transition
    # - condition:
    # - error:

    transition_klass = klass
    state_klass = source
    @transitions[state_klass] = transition_klass
    nil
  end

  def transitions(*sources)
    sources = self.states.keys if sources.empty?
    @transitions.slice(*sources).values
  end
end