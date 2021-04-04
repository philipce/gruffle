module Gruffle
  class Transition
    attr_reader :name

    def self.name
      super.split('::').last
    end

    # TODO: what are the threading implications of newing this up as an instance?
    # What code is thread safe? Reentrant? What about sharing memory?
    def initialize(side_effectors: nil, logger: nil)
      @name = self.class.name

      # TODO: make these available through side_effectors and log_event methods
      # - logger should default not to nil but to the standard gruffle logger
      @side_effectors = side_effectors
      @logger = logger
    end

    def call(state)
      Transition::Result.new(successors: nil)
    end

    def side_effectors
      # TODO: figure out how a workflow wraps the user's values into this side_effectors collection
      # - would be nice if side_effector were an open struct or something, i.e. side_effectors.s3 rather than side_effectors[:s3]
      @side_effectors
    end

    def log_event(hash)
      # TODO: decide on and spec the log_event method interface
      # It needs to align with whatever the interface Gruffle requires of loggers
      return if @logger.nil?
      @logger.log_event(hash)
    end
  end
end