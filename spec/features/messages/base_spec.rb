require 'rails_helper'

RSpec.shared_examples 'a helper which yields message of kind' do |klass, target, *args|
  let(:klazz) { public_send(klass) }

  let(:instance) do
    subject.public_send(target, *(args.map { |i| public_send(i) }))
  end

  it_behaves_like 'a message instance of kind', :klazz, :instance
end

RSpec.shared_examples 'a message instance of kind' do |klass, target|
  let(:kind) { public_send(klass) }
  let(:victim) { public_send(target) }

  it "returns an instance of #{klass}" do
    expect(victim).to be_a(kind)
  end

  context '#serialization' do
    it 'serializes and deserializes properly' do
      expect(victim.to_session).to be_a(String)

      another_victim = victim.class.from_session(victim.to_session)

      expect(another_victim).to eq(victim)
    end
  end

  # Note: inherits default_message from calling context
  context '#message' do
    it 'has the expected message' do
      expect(victim.message).to eq(default_message)
    end
  end

  context '#eql?' do
    it 'equals another message instance with the same string' do
      another_victim = victim.dup
      expect(another_victim).to eq(victim)
      expect(another_victim.__id__).not_to eq(victim.__id__)
    end
  end

  context '#match?' do
    it 'matches the string value' do
      expect(victim).to match(victim.message)
    end
  end

  context '#type?' do
    it 'exposes its type helper properly' do
      expect(victim.public_send("#{victim.level}?")).to be_truthy
    end
  end
end

RSpec.describe FlashMessenger::Messages::Base do
  subject { FlashMessenger::Messages::Base }

  let(:default_translation) { 'development.lorem_ipsum_1' }
  let(:default_message) { I18n.t(default_translation) }
  let(:default_level) { :notice }
  let(:default_params) { { test: 'foo' } }

  context 'with vanilla messages' do
    let(:new_with_message) do
      subject.new(default_level, default_message, default_params)
    end

    context '#new' do
      it 'returns a new FlashMessenger::Messages::Nonpersistent object' do
        expect(new_with_message).to be_a(subject)
      end

      it 'is defines the interface' do
        expect { new_with_message.persistent? }.to raise_error(NotImplementedError)
      end

      it_behaves_like 'a message instance of kind', :subject, :new_with_message
    end
  end

  context 'with i18n translations' do
    let(:new_with_translation) do
      subject.new(default_level, default_translation, default_params)
    end

    context '#new' do
      it 'returns a new FlashMessenger::Messages::Nonpersistent object' do
        expect(new_with_translation).to be_a(subject)
      end

      it 'is defines the interface' do
        expect { new_with_translation.persistent? }.to raise_error(NotImplementedError)
      end

      it_behaves_like 'a message instance of kind', :subject, :new_with_translation
    end
  end
end
