module WorkflowTransitions
  def transition(transition_class, origin:)
    # TODO: allow other options when declaring transition
    # - condition:
    # - error:

    @transitions[origin] = transition_class
    nil
  end

  def transitions(*sources)
    sources = self.states.keys if sources.empty?
    @transitions.slice(*sources).values
  end
end