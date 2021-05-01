module Gruffle
  class StateTransition
    attr_reader :origin
    attr_reader :successors
    attr_reader :status
    attr_reader :started_at
    attr_reader :ended_at
    attr_reader :duration

    def initialize(successors:)
      @successors = process_successors(successors)
    end

    private

    def process_successors(successors)
      successors = array_wrap(successors)
      successors = hash_wrap(successors)
      successors.map { |s| Successor.new(**s) }
    end

    def array_wrap(successors)
      # Note: simply calling Array(successors) does not work when a single hash is passed in; it converts to array
      return [] if successors.nil?
      successors.is_a?(Array) ? successors : [successors]
    end

    def hash_wrap(successors)
      successors.map { |s| s.is_a?(Gruffle::State) ? {state: s} : s }
    end

    #=================================================================================================================
    # Methods below are used by the workflow engine to add data to a user supplied transition result; this saves the
    # user from having to collect/supply this data in each of their transitions.

    def name=(name)
      @name = name
    end

    # TODO: what validation, if any, should be applied to status?
    # Seems like :ok, :retry, and :error are the only statuses we'll need. Are there others? Should we validate? Or is
    # there a reason that users may want custom statuses? Current thought is, custom stuff should go in payload
    #
    # Also need to figure out whether this will be stored as string or symbol. I prefer symbol, but we'd need to parse
    # that in deserializing (e.g. in trace point)
    def status=(status)
      @status = status
    end

    def message=(message)
      @message = message
    end

    def started_at=(started_at)
      @started_at = started_at
    end

    def ended_at=(ended_at)
      @ended_at = ended_at
    end

    def duration=(duration)
      @duration = duration
    end
  end

  class Successor
    attr_reader :state
    attr_reader :delay
    attr_reader :checkpoint

    def initialize(state:, delay: 0, checkpoint: true)
      @state = state
      @delay = delay
      @checkpoint = checkpoint
    end
  end
end