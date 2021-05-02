module Gruffle
  class LocalStateStore
    # TODO: revisit the state store interface
    # - what common methods need to be on every adapter (e.g. redis, postgres, etc)

    def initialize
      @states = {}
    end

    # FIXME: all this needs to be made thread-safe and resilient!

    def by_class(*state_classes)
      @states.values.select { |state| state_classes.include?(state.class) }
    end

    def add(state)
      # TODO: raise error if trying to override existing state
      @states[state.id] = state
    end

    def get(id)
      @states[id]
    end
  end
end