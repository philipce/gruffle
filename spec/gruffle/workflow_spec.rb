require 'spec_helper'

describe Gruffle::Workflow do
  describe 'workflow validation' do
    class GoodWorkflow < Gruffle::Workflow
      @dummy_validation = true
    end

    class BadWorkflow < Gruffle::Workflow
      @dummy_validation = false
    end

    it 'determines if a workflow is valid' do
      expect(GoodWorkflow).to be_valid
      expect(BadWorkflow).to be_invalid
    end

    it 'returns error messages' do
      expect(GoodWorkflow.errors).to eq []
      expect(BadWorkflow.errors).to eq ['dummy']
    end
  end

  describe 'workflow states' do
    class InitialState < Gruffle::State; end
    class RegularState1 < Gruffle::State; end
    class RegularState2 < Gruffle::State; end
    class SyncState < Gruffle::State; end
    class FinalState < Gruffle::State; end

    class StatesWorkflow < Gruffle::Workflow
      # TODO: add real validations, remove dummy validation
      @dummy_validation = true

      initial_state InitialState
      state RegularState1
      state RegularState2
      sync_state SyncState
      final_state FinalState
    end

    before do
      expect(StatesWorkflow).to be_valid
    end

    it 'can declare different types of states' do
      expect(StatesWorkflow.states(:initial).keys).to match_array [InitialState]
      expect(StatesWorkflow.states(:regular).keys).to match_array [RegularState1, RegularState2]
      expect(StatesWorkflow.states(:sync).keys).to match_array [SyncState]
      expect(StatesWorkflow.states(:final).keys).to match_array [FinalState]
      expect(StatesWorkflow.states(:initial, :final).keys).to match_array [InitialState, FinalState]
      expect(StatesWorkflow.states(:regular, :sync, :final).keys).to match_array [RegularState1, RegularState2, SyncState, FinalState]
      expect(StatesWorkflow.states.keys).to match_array [InitialState, RegularState1, RegularState2, SyncState, FinalState]
    end

    it 'ignores invalid types' do
      expect(StatesWorkflow.states(:initial, :foobar).keys).to match_array [InitialState]
    end
  end
end