module Gruffle
  class LocalWorkQueue
    # TODO: revisit the work queue interface
    # - what common methods need to be on every adapter (e.g. redis, sqs, etc)

    def initialize
      @state_ids = []
    end

    # FIXME: all this needs to be made thread-safe and resilient!

    def next
      @state_ids.shift
    end

    def add(id)
      @state_ids.push(id)
    end
  end
end