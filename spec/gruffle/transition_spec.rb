require 'spec_helper'

describe Gruffle::Transition do
  let(:uuid) { SecureRandom.uuid }
  let(:state) { Gruffle::State.new(workflow_name: 'Foo', workflow_id: uuid, payload: {a: 1}) }
  let(:transition) { Gruffle::Transition.new }

  it 'has a name' do
    expect(transition.name).to eq 'Transition'
  end

  it 'returns a result when called with a state' do
    result = transition.call(state)
    expect(result.is_a? Gruffle::Transition::Result).to eq true
  end

  it 'has a side_effectors method' do
    expect(transition).to respond_to :side_effectors
  end

  it 'has a log_events method' do
    expect(transition).to respond_to :log_event
  end
end