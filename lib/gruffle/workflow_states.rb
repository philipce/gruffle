require 'set'

module WorkflowStates
  # TODO: any other state types to add? E.g. add :error type?
  # Maybe a workflow only gets a single final state? Error states could be a different state type, not final. That
  # means we could add an error_state method that would let you declare what states to rescue with which error states
  STATE_TYPES = Set.new([:initial, :regular, :sync, :final]).freeze

  def initial_state(klass)
    add_state(klass, { type: :initial })
  end

  def state(klass)
    add_state(klass, { type: :regular })
  end

  def sync_state(klass)
    add_state(klass, { type: :sync })
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