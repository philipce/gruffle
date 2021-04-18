module Gruffle

  # TODO: figure out how passing config works when declaring adapters
  # If the declaration of an adapter requires newing up an instance of an adapter with a config hash... does that cause
  # problems? I think then, any process would have to run _all_ instances of a workflow against the same backing queue.
  # Maybe that's not an issue though--why would you want a single process running instances of the same workflow against
  # other backing queues?
  #
  # Maybe a nice interface would look like Gruffle::Redis::WorkQueue(config_hash), where there's a method named the same
  # as the class?
  #
  # Maybe the interface should require the user to define their own class, for example:
  #
  #    class MyWorkflow < Gruffle::Workflow
  #      state SomeState
  #
  #      work_queue MyWorkQueue
  #    end
  #
  #    class MyWorkQueue
  #      HOST = 'somehost'
  #      PORT = 6379
  #      PASSWORD = 'somepassword'
  #
  #      @redis_adapter = Gruffle::Redis::WorkQueue.new({host: HOST, port: PORT, password: PASSWORD})
  #
  #      def foo(x)
  #        @redis_adapter.foo(x)
  #      end
  #
  #      def bar
  #        @redis_adapter.bar
  #      end
  #    end
  #
  # Here specifically, I'm talking about the work queue. But it applies to other adapters too, like the state store.

  class LocalWorkQueue

    def initialize
      @state_ids = []
    end

    # TODO: all this needs to be made thread-safe and resilient!

    def next
      @state_ids.shift
    end

    def add(id)
      @state_ids.push(id)
    end
  end
end