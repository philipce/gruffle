module WorkflowStateStore
  def state_store(adapter = nil)
    return assign_state_store_adapter(adapter) unless adapter.nil?
    get_state_store_adapter
  end

  private

  def assign_state_store_adapter(adapter)
    @state_store = adapter
    nil
  end

  DEFAULT_STATE_STORE = Gruffle::LocalStateStore

  def get_state_store_adapter
    @state_store || DEFAULT_STATE_STORE
  end
end