module WorkflowStateStore
  def state_store(adapter = nil, config: nil)
    assign_state_store_adapter(adapter, config) and return if adapter # TODO: and return syntax
    get_state_store_adapter
  end

  private

  DEFAULT_STATE_STORE = Gruffle::LocalStateStore

  def assign_state_store_adapter(adapter = nil, config = nil)
    adapter ||= DEFAULT_STATE_STORE
    @state_store = adapter
    @state_store_config = config
    nil
  end

  def get_state_store_adapter
    assign_state_store_adapter unless @state_store
    { adapter: @state_store, config: @state_store_config }
  end
end