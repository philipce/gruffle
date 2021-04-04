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
end