module WorkflowWorkQueue
  def work_queue(adapter = nil)
    return assign_work_queue_adapter(adapter) unless adapter.nil?
    get_work_queue_adapter
  end

  private

  def assign_work_queue_adapter(adapter)
    @work_queue = adapter
    nil
  end

  DEFAULT_WORK_QUEUE = Gruffle::LocalWorkQueue

  def get_work_queue_adapter
    @work_queue || DEFAULT_WORK_QUEUE
  end
end