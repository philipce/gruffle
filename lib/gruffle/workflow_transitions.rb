module WorkflowTransitions
  def transition(transition_class, origin:)
    # TODO: allow other options when declaring transition
    # - error (so you can customize how to handle errors for a particular state transition)
    # - work_queue (e.g. so you can process different state transitions on different hardware)

    @transitions[origin] = transition_class
    nil
  end

  def transitions(*sources)
    sources = self.states.keys if sources.empty?
    @transitions.slice(*sources).values
  end
end