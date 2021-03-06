require 'spec_helper'

describe Gruffle::Transition do
  let(:uuid) { SecureRandom.uuid }
  let(:state) { Gruffle::State.new(workflow_name: 'Foo', execution_id: uuid, payload: {a: 1}) }
  let(:transition) { Gruffle::Transition.new }

  it 'has a name' do
    expect(transition.name).to eq 'Gruffle::Transition'
  end

  it 'requires a subclass to override process method' do
    expect { transition.process(state) }.to raise_error /must implement process method/
  end

  it 'provides access to state_store' do
    expect(transition).to respond_to :state_store
  end

  it 'provides access to side_effectors' do
    expect(transition).to respond_to :side_effectors
  end

  it 'provides access to logger' do
    expect(transition).to respond_to :logger
  end
end