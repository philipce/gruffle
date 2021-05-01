require 'spec_helper'

describe Gruffle::Trace do
  let(:uuid) { SecureRandom.uuid }

  it 'initializes to an empty trace' do
    trace = described_class.new
    expect(trace).to be_empty
  end

  it 'can act as an array of points' do
    state_1 = Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid)
    trace = described_class.new

    # TODO: push method should take transition and transition_result too (here and everywhere else it's called)
    trace.push(state: state_1)
    expect(trace.length).to eq 1
    expect(trace).to_not be_empty
    expect(trace[0]).to eq trace.first
    expect(trace[-1]).to eq trace.last
    expect(trace.first.state_name).to eq state_1.name

    state_2 = Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid)
    trace.push(state: state_2)
    expect(trace.first.state_name).to eq state_1.name
    expect(trace.last.state_name).to eq state_2.name
  end

  it 'can be compared against other traces for equality' do
    state = Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid)
    trace_1 = described_class.new
    trace_2 = described_class.new
    trace_1.push(state: state)
    trace_2.push(state: state)
    expect(trace_1).to eq trace_2
    expect(trace_1.eql?(trace_2)).to eq true
  end

  it 'can create a deep copy of itself' do
    state = Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid)
    trace_1 = described_class.new
    trace_2 = trace_1.deep_dup
    trace_2.push(state: state)
    expect(trace_2.length).to eq 1
    expect(trace_1.length).to eq 0
  end

  describe '#to_json' do
    it 'serializes to json' do
      trace = described_class.new
      str = trace.to_json
      expect { JSON.parse(str) }.to_not raise_error
    end
  end

  describe '.from_hash' do
    class FooState < Gruffle::State; end
    class BarState < Gruffle::State; end

    it 'recreates a trace object from the hash representation' do
      state_1 = FooState.new(workflow_name: 'Foo', execution_id: uuid)
      state_2 = BarState.new(workflow_name: 'Bar', execution_id: uuid)
      original_trace = described_class.new
      original_trace.push(state: state_1)
      original_trace.push(state: state_2)
      hash = JSON.parse(original_trace.to_json, symbolize_names: true)
      recreated_trace = described_class.from_hash(hash)
      expect(recreated_trace.length).to eq 2
      expect(recreated_trace.first.state_name).to eq state_1.name
      expect(recreated_trace.last.state_name).to eq state_2.name
      expect(recreated_trace.last.state_id).to eq state_2.id
      expect(Time.now - recreated_trace.last.state_created_at).to be < 1
    end
  end

  describe 'point in a trace' do
    let(:state) { Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid) }
    let(:trace) { described_class.new }
    let(:point) { trace.last }

    before do
      trace.push(state: state)
    end

    it 'provides relevant state attributes' do
      # TODO: push method should take transition and transition_result too
      expect(point.state_name).to eq state.name
      expect(point.state_id).to eq state.id
      expect(point.state_created_at).to eq state.created_at
    end

    it 'can be compared against other points for equality' do
      trace.push(state: state)

      point_1 = trace.first
      point_2 = trace.last
      expect(point_1).to eq point_2
      expect(point_1.eql?(point_2)).to eq true
    end
  end
end