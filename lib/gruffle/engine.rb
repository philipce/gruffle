module Gruffle
  class Engine
    def self.run(workflow)
      if workflow.is_a? Gruffle::Workflow
        run_instance(workflow)
      elsif workflow.respond_to?(:<) && workflow < Gruffle::Workflow
        raise "run_klass not supported yet!" # TODO: implement
      else
        raise "Unable to run workflow: #{workflow}" # TODO: define gruffle error types
      end
    end

    private

    def self.run_instance(workflow)
      workflow_klass = workflow.class
      work_queue = workflow_klass.work_queue
      next_work = work_queue.next

      while next_work
        puts "working hard #{next_work}"
        sleep 1
      end


    end


  end
end