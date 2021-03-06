require 'spec_helper'

describe Gruffle::State do
  let(:uuid) { SecureRandom.uuid }

  describe '#initialize' do
    it 'has the necessary attributes' do
      state = described_class.new(workflow_name: 'Foo', execution_id: uuid)
      expect(state.workflow_name).to eq 'Foo'
      expect(state.execution_id).to match UUID_REGEX
      expect(state.name).to eq 'Gruffle::State'
      expect(state.id).to match UUID_REGEX
      expect(state.trace).to be_empty
      expect(state.fork_token).to eq nil
      expect(state.join_tokens).to be_empty
      expect(Time.now - state.created_at).to be < 1
      expect(state.payload).to eq Hash.new
    end

    it 'requires workflow name' do
      name = 'Foo'
      expect { described_class.new(workflow_name: name, execution_id: uuid) }.to_not raise_error
      expect(described_class.new(workflow_name: name, execution_id: uuid).workflow_name).to eq name
      expect { described_class.new }.to raise_error ArgumentError
    end

    it 'optionally takes a payload' do
      payload = { a: 1 }
      state_with_payload = described_class.new(workflow_name: 'Foo', execution_id: uuid, payload: payload)
      state_without_payload = described_class.new(workflow_name: 'Foo', execution_id: uuid)
      expect(state_with_payload.payload).to eq payload
      expect(state_without_payload.payload).to eq Hash.new
    end

    it 'symbolizes payload keys' do
      payload = { 'a' => 1 }
      state = described_class.new(workflow_name: 'Foo', execution_id: uuid, payload: payload)
      expect(state.payload).to eq payload.transform_keys(&:to_sym)
    end

    it 'duplicates the payload' do
      payload = { a: 1 }
      state = described_class.new(workflow_name: 'Foo', execution_id: uuid, payload: payload)
      expect(state.payload.equal?(payload)).to eq false
    end
  end

  describe '#serialize' do
    it 'serializes to json' do
      state = described_class.new(workflow_name: 'Foo', execution_id: uuid)
      str = state.serialize
      expect { JSON.parse(str) }.to_not raise_error
    end
  end

  describe '.deserialize' do
    it 'recreates a state object from the serialized representation' do
      original_state = described_class.new(workflow_name: 'Foo', execution_id: uuid, payload: {a: 1})
      recreated_state = described_class.deserialize(original_state.serialize)
      expect(recreated_state).to eq original_state
      expect(recreated_state.workflow_name).to eq original_state.workflow_name
      expect(recreated_state.execution_id).to eq original_state.execution_id
      expect(recreated_state.name).to eq original_state.name
      expect(recreated_state.id).to eq original_state.id
      expect(recreated_state.trace).to eq original_state.trace
      expect(recreated_state.fork_token).to eq original_state.fork_token
      expect(recreated_state.join_tokens).to eq original_state.join_tokens
      expect((original_state.created_at - recreated_state.created_at).abs).to be < 1
      expect(recreated_state.payload).to eq original_state.payload
    end
  end

  describe '.derive' do
    class OriginalState < Gruffle::State; end
    class SuccessorState < Gruffle::State; end

    it 'creates a successor state based on the original state, with an empty payload by default' do
      original_state = OriginalState.new(workflow_name: 'Foo', execution_id: uuid)
      successor_state = SuccessorState.derive(original_state)

      expect(successor_state.class).to eq SuccessorState
      expect(successor_state.workflow_name).to eq original_state.workflow_name
      expect(successor_state.execution_id).to eq original_state.execution_id
      expect(successor_state.name).to eq 'SuccessorState'
      expect(successor_state.id).to match UUID_REGEX
      expect(successor_state.id).to_not eq original_state.id
      expect(successor_state.trace.length).to eq original_state.trace.length + 1
      expect(successor_state.trace.last.state_name).to eq original_state.name
      expect(Time.now - successor_state.created_at).to be < 1
      expect(successor_state.payload).to eq(Hash.new)
    end

    it 'allows setting a new payload' do
      original_state = OriginalState.new(workflow_name: 'Foo', execution_id: uuid)
      payload = { omg: 'itworks' }
      successor_state = SuccessorState.derive(original_state, payload: payload)
      expect(successor_state.payload).to eq(payload)
    end
  end
end

