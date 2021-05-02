require 'spec_helper'

describe Gruffle::StateTransition do
  let(:uuid) { SecureRandom.uuid }
  let(:state_1) { Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid, payload: {a: 1}) }
  let(:state_2) { Gruffle::State.new(workflow_name: 'Bar', execution_id: uuid, payload: {b: 2}) }

  describe 'successors' do
    it 'takes an array of successors' do
      states = [state_1, state_2]
      state_transition = described_class.new(successors: states)
      expect(state_transition.successors.count).to eq states.count
    end

    it 'allows a single successor' do
      state_transition = described_class.new(successors: state_1)
      expect(state_transition.successors.count).to eq 1
    end

    it 'provides successors that can answer the needed questions' do
      state_transition = described_class.new(successors: state_1)
      successor = state_transition.successors.first
      expect(successor.state).to eq state_1
      expect(successor).to respond_to :delay
      expect(successor).to respond_to :checkpoint
    end

    it 'adds default options to plain successor states' do
      state_transition = described_class.new(successors: state_1)
      successor = state_transition.successors.first
      expect(successor.state).to eq state_1
      expect(successor.delay).to eq 0
      expect(successor.checkpoint).to eq true
    end

    it 'allows specifying options along with the successor state' do
      state_transition = described_class.new(successors: { state: state_1, delay: 15, checkpoint: false })
      successor = state_transition.successors.first
      expect(successor.state).to eq state_1
      expect(successor.delay).to eq 15
      expect(successor.checkpoint).to eq false
    end

    it 'supports having no successors' do
      state_transition = described_class.new(successors: [])
      expect(state_transition.successors.count).to eq 0
      state_transition = described_class.new(successors: nil)
      expect(state_transition.successors.count).to eq 0
    end
  end

  describe 'private methods for use by workflow engine' do
    let(:state_transition) { described_class.new(successors: []) }

    it 'can set origin' do
      state_transition.send(:origin=, state_1)
      expect(state_transition.origin).to eq state_1
    end

    it 'can set transition status' do
      status = :ok
      state_transition.send(:status=, status)
      expect(state_transition.status).to eq status
    end

    it 'can set timing data' do
      start = Time.parse('2020-04-04T16:50Z')
      stop = Time.parse('2020-04-04T16:54Z')
      duration = 4.123
      state_transition.send(:started_at=, start)
      state_transition.send(:ended_at=, stop)
      state_transition.send(:duration=, duration)
      expect(state_transition.started_at).to eq start
      expect(state_transition.ended_at).to eq stop
      expect(state_transition.duration).to eq duration
    end
  end
end