require 'spec_helper'

describe Gruffle::Inspector do
  class DummyWorkflow < Gruffle::Workflow; end

  let(:dummy_workflow) { DummyWorkflow.new }
  let(:inspector) { Gruffle::Inspector.new(dummy_workflow) }

  describe '#states' do
    it 'provides read access to the workflow states' do
      expect(inspector).to respond_to :states
    end
  end

  describe '#initial_state' do
    it 'provides read access to the workflow initial state' do
      expect(inspector).to respond_to :initial_state
    end
  end
end