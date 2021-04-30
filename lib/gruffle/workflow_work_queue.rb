module WorkflowWorkQueue
  def work_queue(adapter = nil, config: nil)
    assign_work_queue_adapter(adapter, config) and return if adapter
    get_work_queue_adapter
  end

  private

  DEFAULT_WORK_QUEUE = Gruffle::LocalWorkQueue

  def assign_work_queue_adapter(adapter = nil, config = nil)
    adapter ||= DEFAULT_WORK_QUEUE
    @work_queue = adapter
    @work_queue_config = config
    nil
  end

  def get_work_queue_adapter
    assign_work_queue_adapter unless @work_queue
    { adapter: @work_queue, config: @work_queue_config }
  end
end