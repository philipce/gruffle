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
      workflow_instance = InitializationWorkflow.new(payload)

      # TODO: maybe the instance shouldn't provide the initial state. Maybe the Gruffle::Inspector _takes_ a workflow
      # instance (or class) and then you can query the inspector for whatever states you want
      initial_state = workflow_instance.initial_state

      expect(workflow_instance.id).to match UUID_REGEX
      expect(workflow_instance.id).to eq initial_state.workflow_id
      expect(initial_state.payload).to eq payload
    end
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
    class NonDefaultStateStore; end
    class StateStoreWorkflow < Gruffle::Workflow
      state RegularState1
      state_store NonDefaultStateStore
    end

    class DefaultStateStoreWorkflow < Gruffle::Workflow
      state RegularState1
    end

    before do
      expect(StateStoreWorkflow).to be_valid
      expect(DefaultStateStoreWorkflow).to be_valid
    end

    it 'provides access to the declared state store' do
      expect(StateStoreWorkflow.state_store).to be_a NonDefaultStateStore
    end

    it 'has a default work queue' do
      expect(DefaultStateStoreWorkflow.state_store).to be_a Gruffle::LocalStateStore
    end
  end

  describe 'workflow work queue' do
    class NonDefaultWorkQueue; end
    class WorkQueueWorkflow < Gruffle::Workflow
      state RegularState1
      work_queue NonDefaultWorkQueue
    end

    class DefaultWorkQueueWorkflow < Gruffle::Workflow
      state RegularState1
    end

    before do
      expect(WorkQueueWorkflow).to be_valid
      expect(DefaultWorkQueueWorkflow).to be_valid
    end

    it 'provides access to the declared work queue' do
      expect(WorkQueueWorkflow.work_queue).to be_a NonDefaultWorkQueue
    end

    it 'has a default work queue' do
      expect(DefaultWorkQueueWorkflow.work_queue).to be_a Gruffle::LocalWorkQueue
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