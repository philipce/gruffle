module Gruffle
  class Engine
    class << self
      def run(workflows)
        workflows = initialize_workflows(workflows)
        validate_workflows!(workflows)
        new(workflows).send(:run)
      end

      private

      def initialize_workflows(workflows)
        Array(workflows).map do |workflow|
          if workflow.is_a? Gruffle::Workflow
            workflow
          elsif workflow.respond_to?(:<) && workflow < Gruffle::Workflow
            workflow.new
          else
            # TODO: consider how to consolidate this error handling with other engine raises
            raise "Unable to run workflow: #{workflow}"
          end
        end
      end

      def validate_workflows!(workflows)
        # TODO: check that workflows are all valid and raise if not
      end
    end

    private

    def initialize(workflows)
      @workflow_registry = workflows.each_with_object({}) { |w, hash| hash[w.name] = w }
      @workflow_index = rand(workflows.count)
    end

    def run
      # TODO: add thread pool somewhere in here
      # - Maybe simple enough to roll our own; maybe use an external gem? I'd like to avoid external dependencies...
      # - what happens if a thread has a fatal error? Should the other threads continue? Is it too error prone to try to
      #   self heal and spin up another one? Should the process stop all the other threads and exit with error code?
      #   (I'm leaning toward the later option--recoverable errors should have been caught in Workflow.process so if a
      #   thread ran so far off the rails, there might be a lot wrong. If we exit correctly then e.g. kube or whatever
      #   is managing the processes can spin it back up)

      # TODO: re-evaluate workflow time slicing mechanism
      # TODO: need to decide on what conditions next_state should end loop
      # - maybe returning nil ends the loop; if you want to not end the loop, return an integer >= 0 for how many seconds to sleep?
      while next_workflow and next_state
        puts "working hard on #{current_state}"

        state_transition = current_workflow.send(:process, current_state)

        # TODO: handle state transition successor options
        # - e.g. delay, checkpoint

        current_state_store.complete(state_transition)
        current_work_queue.complete(state_transition)
      end
    rescue => e

      # TODO: how to handle errors?
      # Workflow process method should catch user errors... what even can get raise that would get rescued here?
      # Maybe best thing is just to exit process with appropriate error code?
      # Maybe engine can take a logger object? Maybe the `DEFAULT_LOGGER` that's on a workflow should actually be a gem
      # level logger, then the engine could use that too

      raise e
    end

    def current_state
      @current_state
    end

    def next_state
      @current_state = current_workflow.send(:next_state)
      @current_state
    end

    def current_workflow
      @current_workflow
    end

    def next_workflow
      @current_workflow = @workflow_registry.values[next_workflow_index]
      @current_workflow
    end

    def current_workflow_index
      @current_workflow_index
    end

    def next_workflow_index
      @current_workflow_index = (@workflow_index += 1) % @workflow_registry.count
      @current_workflow_index
    end
  end
end