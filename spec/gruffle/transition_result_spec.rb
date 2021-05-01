require 'spec_helper'

describe Gruffle::Transition::Result do
  let(:uuid) { SecureRandom.uuid }
  let(:state_1) { Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid, payload: {a: 1}) }
  let(:state_2) { Gruffle::State.new(workflow_name: 'Bar', execution_id: uuid, payload: {b: 2}) }

  describe 'successors' do
    it 'takes an array of successors' do
      states = [state_1, state_2]
      result = described_class.new(successors: states)
      expect(result.successors.count).to eq states.count
    end

    it 'allows a single successor' do
      result = described_class.new(successors: state_1)
      expect(result.successors.count).to eq 1
    end

    it 'provides successors that can answer the needed questions' do
      result = described_class.new(successors: state_1)
      successor = result.successors.first
      expect(successor.state).to eq state_1
      expect(successor).to respond_to :wait
      expect(successor).to respond_to :checkpoint
    end

    it 'adds default options to plain successor states' do
      result = described_class.new(successors: state_1)
      successor = result.successors.first
      expect(successor.state).to eq state_1
      expect(successor.wait).to eq 0
      expect(successor.checkpoint).to eq true
    end

    it 'allows specifying options along with the successor state' do
      result = described_class.new(successors: { state: state_1, wait: 15, checkpoint: false })
      successor = result.successors.first
      expect(successor.state).to eq state_1
      expect(successor.wait).to eq 15
      expect(successor.checkpoint).to eq false
    end

    it 'supports having no successors' do
      result = described_class.new(successors: [])
      expect(result.successors.count).to eq 0
      result = described_class.new(successors: nil)
      expect(result.successors.count).to eq 0
    end
  end

  describe 'private methods for use by workflow engine' do
    let(:result) { described_class.new(successors: []) }

    it 'can set the transition name' do
      name = 'foobar'
      result.send(:name=, name)
      expect(result.name).to eq name
    end

    it 'can set transition status' do
      status = :ok
      result.send(:status=, status)
      expect(result.status).to eq status
    end

    it 'can set a status message' do
      msg = 'Something specific went wrong'
      result.send(:message=, msg)
      expect(result.message).to eq msg
    end

    it 'can set timing data' do
      start = Time.parse('2020-04-04T16:50Z')
      stop = Time.parse('2020-04-04T16:54Z')
      duration = 4.123
      result.send(:started_at=, start)
      result.send(:stopped_at=, stop)
      result.send(:duration=, duration)
      expect(result.started_at).to eq start
      expect(result.stopped_at).to eq stop
      expect(result.duration).to eq duration
    end
  end
end