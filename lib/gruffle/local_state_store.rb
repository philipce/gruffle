module Gruffle
  class LocalStateStore
    def initialize
      @states = {}
    end

    # FIXME: all this needs to be made thread-safe and resilient!

    def of_class(*state_classes)
      @states.values.select { |state| state_classes.include?(state.class) }
    end

    def add(state)
      # TODO: raise error if trying to override existing state
      @states[state.id] = state
    end
  end
end