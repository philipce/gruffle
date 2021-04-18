module WorkflowStateStore
  # TODO: add named config param with default nil so config can be provided to initialize adapter (e.g. redis connection details)
  def state_store(adapter = nil)
    return assign_state_store_adapter(adapter) unless adapter.nil?
    get_state_store_adapter
  end

  private

  DEFAULT_STATE_STORE = Gruffle::LocalStateStore

  def assign_state_store_adapter(adapter = nil)
    adapter ||= DEFAULT_STATE_STORE
    @state_store = adapter.new
    nil
  end

  def get_state_store_adapter
    assign_state_store_adapter unless @state_store
    @state_store
  end
end