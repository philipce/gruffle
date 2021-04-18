module Gruffle
  class LocalStateStore
    def initialize
      @states = {}
    end

    def by_klass(*klasses)
      @states.select { |_id, state| klasses.include?(state.class) }
    end

    def add(state)
      # TODO: raise error if trying to override existing state
      @states[state.id] = state
    end
  end
end