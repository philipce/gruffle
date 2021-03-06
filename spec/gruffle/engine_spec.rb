require 'spec_helper'

describe Gruffle::Engine do
  class Kickoff < Gruffle::State; end
  class AssignedNumber < Gruffle::State; end
  class SquaredNumber < Gruffle::State; end
  class AllNumbersSquared < Gruffle::State; end
  class SumOfSquares < Gruffle::State; end

  class AssignNumbers < Gruffle::Transition; end
  class SquareNumber < Gruffle::Transition; end
  class SumSquares < Gruffle::Transition; end

  class SumOfSquaresWorkflow < Gruffle::Workflow
    # Given integer n > 0, compute x, where: x = 1^2 + 2^2 + ... + (n-1)^2 + n^2

    initial_state Kickoff
    state AssignedNumber
    state SquaredNumber
    join_state AllNumbersSquared # SquaringComplete?
    final_state SumOfSquares

    transition AssignNumbers, origin: Kickoff
    transition SquareNumber, origin: AssignedNumber
    transition SumSquares, origin: AllNumbersSquared

    state_store Gruffle::LocalStateStore
    work_queue Gruffle::LocalWorkQueue
  end

  before do
    expect(SumOfSquaresWorkflow).to be_valid
  end

  context 'when processing a workflow instance' do
    let(:n) { 10 }
    let(:expected_sum_of_squares) { (1..n).reduce(0) { |sum, n| sum + n**2 } }

    it 'correctly computes the final state' do
      workflow, _ = SumOfSquaresWorkflow.setup(initial_payload: {n: 10})

      Gruffle::Engine.run(workflow)

      inspector = Gruffle::Inspector.new(workflow)
      final_states = inspector.final_states
      final_state = final_states.first

      expect(final_states.count).to eq 1
      expect(final_state).to be_a SumOfSquares
      expect(final_state.sum_of_squares).to eq expected_sum_of_squares
    end
  end

  context 'when processing a class of workflows' do
    # TODO: stub any instance of workflow.class and return states
    it 'works'
  end

  # TODO: pass both instance and class and mock next state methods
  it 'can take a non-homogeneous collection of workflows'

  it 'rejects workflows that it is unable to run'
end