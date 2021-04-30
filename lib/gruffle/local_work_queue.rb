module Gruffle
  class LocalWorkQueue
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