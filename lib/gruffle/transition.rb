module Gruffle
  class Transition
    def initialize(state_store: nil, side_effectors: nil, logger: nil)
      # TODO: come up with better defaults for these params than nil
      # - not sure if there are better defaults for all of them, but e.g. logger could be Gruffle::DEFAULT_LOGGER
      @state_store = state_store
      @side_effectors = side_effectors
      @logger = logger
    end

    def name
      self.class.name
    end

    def call(_state)
      raise "Transition subclass must implement call function"
    end

    def state_store
      # TODO: this should be a stripped down interface into state store
      # - read only view into the state store
      # - possibly restricted to just states in the current execution id
    end

    def side_effectors
      # TODO: figure out how a workflow wraps the user's values into this side_effectors collection
      # - would be nice if side_effector were an open struct or something, i.e. side_effectors.s3 rather than side_effectors[:s3]
      @side_effectors
    end

    def logger
      # TODO: decide on and spec the gruffle logger interface
      # - probably should match the standard ruby logger interface
      @logger
    end
  end
end