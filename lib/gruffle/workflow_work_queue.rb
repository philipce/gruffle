module WorkflowWorkQueue
  # TODO: add named config param with default nil so config can be provided to initialize adapter (e.g. redis connection details)
  def work_queue(adapter = nil)
    return assign_work_queue_adapter(adapter) unless adapter.nil?
    get_work_queue_adapter
  end

  private

  DEFAULT_WORK_QUEUE = Gruffle::LocalWorkQueue

  def assign_work_queue_adapter(adapter = nil)
    adapter ||= DEFAULT_WORK_QUEUE
    @work_queue = adapter.new
    nil
  end

  def get_work_queue_adapter
    assign_work_queue_adapter unless @work_queue
    @work_queue
  end
end