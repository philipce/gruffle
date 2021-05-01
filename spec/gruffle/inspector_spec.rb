require 'spec_helper'

describe Gruffle::Inspector do
  class DummyWorkflow < Gruffle::Workflow; end

  let(:dummy_workflow) { DummyWorkflow.new }
  let(:inspector) { Gruffle::Inspector.new(dummy_workflow) }

  describe '#initialize' do
    it 'can be initialized with a workflow class' do
      i = Gruffle::Inspector.new(dummy_workflow.class)
      expect { i.initial_state }.not_to raise_error
    end

    it 'can be initialized with a workflow instance' do
      i = Gruffle::Inspector.new(dummy_workflow)
      expect { i.initial_state }.not_to raise_error
    end
  end

  describe '#initial_state' do
    it 'provides read access to the workflow states' do
      expect(inspector).to respond_to :initial_state
    end
  end

  describe '#final_states' do
    it 'provides read access to the workflow initial state' do
      expect(inspector).to respond_to :final_states
    end
  end
end