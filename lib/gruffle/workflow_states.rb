require 'set'

module WorkflowStates
  # TODO: any other state types to add? E.g. add :error type?
  # Maybe a workflow only gets a single final state? Error states could be a different state type, not final. That
  # means we could add an error_state method that would let you declare what states to rescue with which error states
  #
  # Maybe there's no need for a sync state; workflow can infer when a fork is terminated (every state transition that
  # returns multiple states requires exactly 1 of them to be a join state; fork token gets handed forward to join state;
  # if a state that had a fork token transitions to 0 states, that's a sync)
  STATE_TYPES = Set.new([:initial, :regular, :sync, :join, :final]).freeze

  # TODO: remove unnecessary _state suffix on methods
  # E.g. initial instead of initial_state

  def initial_state(klass)
    add_state(klass, { type: :initial })
  end

  def state(klass)
    add_state(klass, { type: :regular })
  end

  def sync_state(klass)
    add_state(klass, { type: :sync })
  end

  def join_state(klass)
    add_state(klass, { type: :join })
  end

  def final_state(klass)
    add_state(klass, { type: :final })
  end

  def states(*types)
    types = STATE_TYPES.to_a if types.empty?
    @states.select { |_klass, options| types.include?(options[:type]) }
  end

  private

  def add_state(klass, options)
    @states[klass] = options
    nil
  end
end