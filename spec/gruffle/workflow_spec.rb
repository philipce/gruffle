require 'spec_helper'

describe Gruffle::Workflow do
  class InitialState < Gruffle::State; end
  class RegularState1 < Gruffle::State; end
  class RegularState2 < Gruffle::State; end
  class SyncState < Gruffle::State; end
  class JoinState < Gruffle::State; end
  class FinalState < Gruffle::State; end

  class FirstTransition < Gruffle::Transition; end
  class SecondTransition < Gruffle::Transition; end

  describe '#initialize' do
    class InitializationWorkflow < Gruffle::Workflow
      initial_state InitialState
      final_state FinalState
    end

    before do
      expect(InitializationWorkflow).to be_valid
    end

    it 'returns a workflow instance with initial state' do
      payload = { foo: 123 }
      workflow_instance, execution_id = InitializationWorkflow.setup(initial_payload: payload)

      inspector = Gruffle::Inspector.new(workflow_instance)
      initial_state = inspector.initial_state

      expect(execution_id).to match UUID_REGEX
      expect(initial_state.execution_id).to eq execution_id
      expect(initial_state.payload).to eq payload
    end
  end

  describe '#name' do
    class NameWorkflow < Gruffle::Workflow
      initial_state InitialState
      final_state FinalState
    end

    it 'responds with the class name' do
      workflow = NameWorkflow.new
      expect(workflow.name).to eq NameWorkflow.name
    end
  end

  describe '#process' do
    class ProcessWorkflow < Gruffle::Workflow
      initial_state InitialState
      final_state FinalState

      transition FirstTransition, source: InitialState
    end

    it 'can apply the correct transition to the given state' do
      workflow = ProcessWorkflow.new
      uuid = SecureRandom.uuid
      state = InitialState.new(workflow_name: workflow, execution_id: uuid)

      expect_any_instance_of(FirstTransition).to receive(:call).with(state)
      state_transition = workflow.send(:process, state)

      # TODO: expect all fields to be filled out (e.g. origin, timing info, etc)
      expect(state_transition.successors).to eq FinalState
      expect(state_transition.status).to eq :ok
    end

    # TODO: try passing by something other than a state transition and watch it blow up
    it 'ensures a state transition is returned'

  end

  describe 'workflow states' do
    class StatesWorkflow < Gruffle::Workflow
      initial_state InitialState
      state RegularState1
      state RegularState2
      sync_state SyncState
      join_state JoinState
      final_state FinalState
    end

    before do
      expect(StatesWorkflow).to be_valid
    end

    it 'can declare different types of states' do
      expect(StatesWorkflow.states(:initial).keys).to match_array [InitialState]
      expect(StatesWorkflow.states(:regular).keys).to match_array [RegularState1, RegularState2]
      expect(StatesWorkflow.states(:sync).keys).to match_array [SyncState]
      expect(StatesWorkflow.states(:join).keys).to match_array [JoinState]
      expect(StatesWorkflow.states(:final).keys).to match_array [FinalState]
      expect(StatesWorkflow.states(:initial, :final).keys).to match_array [InitialState, FinalState]
      expect(StatesWorkflow.states(:regular, :sync, :final).keys).to match_array [RegularState1, RegularState2, SyncState, FinalState]
      expect(StatesWorkflow.states.keys).to match_array [InitialState, RegularState1, RegularState2, SyncState, JoinState, FinalState]
    end

    it 'ignores invalid types' do
      expect(StatesWorkflow.states(:initial, :foobar).keys).to match_array [InitialState]
    end
  end

  describe 'workflow transitions' do
    class TransitionsWorkflow < Gruffle::Workflow
      initial_state InitialState
      state RegularState1
      final_state FinalState

      transition FirstTransition, source: InitialState
      transition SecondTransition, source: RegularState1
    end

    before do
      expect(StatesWorkflow).to be_valid
    end

    it 'can declare transitions' do
      expect(TransitionsWorkflow.transitions).to match_array [FirstTransition, SecondTransition]
      expect(TransitionsWorkflow.transitions(InitialState)).to match_array [FirstTransition]
      expect(TransitionsWorkflow.transitions(InitialState, RegularState1)).to match_array [FirstTransition, SecondTransition]
      expect(TransitionsWorkflow.transitions(FinalState)).to eq []
    end
  end

  describe 'workflow state store' do
    class DefaultStateStoreWorkflow < Gruffle::Workflow
      state RegularState1
    end

    class NonDefaultStateStore; end

    class StateStoreWorkflow < Gruffle::Workflow
      state RegularState1
      state_store NonDefaultStateStore
    end

    class StateStoreConfigWorkflow < Gruffle::Workflow
      state RegularState1
      state_store NonDefaultStateStore, config: { foo: 123 }
    end

    before do
      expect(StateStoreWorkflow).to be_valid
      expect(DefaultStateStoreWorkflow).to be_valid
    end

    it 'has a default work queue' do
      expect(DefaultStateStoreWorkflow.state_store[:adapter]).to eq Gruffle::LocalStateStore
    end

    it 'provides access to the declared state store' do
      expect(StateStoreWorkflow.state_store[:adapter]).to eq NonDefaultStateStore
      expect(StateStoreWorkflow.state_store[:config]).to eq nil
    end

    it 'provides access to the declared state store and its config' do
      expect(StateStoreConfigWorkflow.state_store[:adapter]).to eq NonDefaultStateStore
      expect(StateStoreConfigWorkflow.state_store[:config]).to eq({ foo: 123 })
    end
  end

  describe 'workflow work queue' do
    class DefaultWorkQueueWorkflow < Gruffle::Workflow
      state RegularState1
    end

    class NonDefaultWorkQueue; end

    class WorkQueueWorkflow < Gruffle::Workflow
      state RegularState1
      work_queue NonDefaultWorkQueue
    end

    class WorkQueueWorkflow < Gruffle::Workflow
      state RegularState1
      work_queue NonDefaultWorkQueue, config: { bar: 456 }
    end

    before do
      expect(WorkQueueWorkflow).to be_valid
      expect(DefaultWorkQueueWorkflow).to be_valid
    end

    it 'has a default work queue' do
      expect(DefaultWorkQueueWorkflow.work_queue[:adapter]).to eq Gruffle::LocalWorkQueue
    end

    it 'provides access to the declared work queue' do
      expect(WorkQueueWorkflow.work_queue[:adapter]).to eq NonDefaultWorkQueue
      expect(WorkQueueWorkflow.work_queue[:config]).to eq({ bar: 456 })
    end
  end

  describe 'workflow validation' do
    class SingleStateWorkflow < Gruffle::Workflow
      state RegularState1
    end

    class ZeroStateWorkflow < Gruffle::Workflow; end

    class NotAGruffleState; end
    class NotAGruffleTransition; end
    class NonConformingInheritanceWorkflow < Gruffle::Workflow
      state NotAGruffleState
      transition NotAGruffleTransition, source: NotAGruffleState
    end

    class AbstractBassClassWorkflow < Gruffle::Workflow
      state Gruffle::State
      transition Gruffle::Transition, source: Gruffle::State
    end

    it 'provides methods to determine workflow validity' do
      expect(SingleStateWorkflow).to respond_to :valid?
      expect(SingleStateWorkflow).to respond_to :invalid?
      expect(SingleStateWorkflow).to respond_to :errors
    end

    it 'ensures at least one state is declared' do
      expect(SingleStateWorkflow).to be_valid
      expect(SingleStateWorkflow.errors).to eq []

      expect(ZeroStateWorkflow).to be_invalid
      expect(ZeroStateWorkflow.errors).to include(match /at least one state/)
    end

    it 'requires correct state inheritance' do
      expect(NonConformingInheritanceWorkflow).to be_invalid
      expect(NonConformingInheritanceWorkflow.errors).to include(match /must inherit from Gruffle::State/)
    end

    it 'does not allow declaring states of abstract base type' do
      expect(AbstractBassClassWorkflow).to be_invalid
      expect(AbstractBassClassWorkflow.errors).to include(match /must inherit from Gruffle::State/)
    end

    it 'requires correct transition inheritance' do
      expect(NonConformingInheritanceWorkflow).to be_invalid
      expect(NonConformingInheritanceWorkflow.errors).to include(match /must inherit from Gruffle::Transition/)
    end

    it 'does not allow declaring transitions of abstract base type' do
      expect(AbstractBassClassWorkflow).to be_invalid
      expect(AbstractBassClassWorkflow.errors).to include(match /must inherit from Gruffle::Transition/)
    end
  end
end