module Gruffle
  class Engine
    class << self
      def run(workflows)
        workflows = initialize_workflows(workflows)
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
            raise "Unable to run workflow: #{workflow}"
          end
        end
      end
    end

    private

    def initialize(workflows)
      @workflow_registry = workflows.each_with_object({}) { |w, hash| hash[w.name] = w }
      @workflow_index = rand(workflows.count)
    end

    def run
      next_workflow

      while next_state
        puts "working hard #{current_state}"
        sleep 1
      end
    end

    def current_state
      @current_state
    end

    def next_state
      @current_state = current_workflow.next_state
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