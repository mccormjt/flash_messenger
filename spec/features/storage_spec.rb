require 'rails_helper'

RSpec.describe FlashMessenger::Storage do
  subject { FlashMessenger::Storage.new }

  let(:nonpersistent_message_klass) { FlashMessenger::Messages::Nonpersistent }
  let(:persistent_message_klass) { FlashMessenger::Messages::Persistent }

  let(:default_klass) { nonpersistent_message_klass }
  let(:default_translation) { 'development.lorem_ipsum_1' }
  let(:default_message) { I18n.t(default_translation) }
  let(:default_level) { :notice }
  let(:default_params) { { test: 'foo' } }

  let(:first_message) { subject.messages.first }
  let(:second_message) { subject.messages[1] }
  let(:third_message) { subject.messages[2] }
  let(:last_message) { subject.messages.last }

  context '#new' do
    it 'returns a new FlashMessenger::Storage object' do
      expect(subject).to be_a(FlashMessenger::Storage)
    end

    it 'with an empty message array' do
      expect(subject.messages).to be_a(Array)
      expect(subject.messages).to be_empty
    end
  end

  context '#alert' do
    let(:alert) { default_klass.alert(default_message) }

    it_behaves_like 'a public accessor method',
      :alert,
      :default_message

    it_behaves_like 'a helper which yields message of kind', :default_klass,
      :alert,
      :default_message
  end

  context '#error' do
    let(:error) { default_klass.error(default_message) }

    it_behaves_like 'a public accessor method',
      :error,
      :default_message

    it_behaves_like 'a helper which yields message of kind', :default_klass,
      :error,
      :default_message
  end

  context '#info' do
    let(:info) { default_klass.info(default_message) }

    it_behaves_like 'a public accessor method',
      :info,
      :default_message

    it_behaves_like 'a helper which yields message of kind', :default_klass,
      :info,
      :default_message
  end

  context '#notice' do
    let(:notice) { default_klass.notice(default_message) }

    it_behaves_like 'a public accessor method',
      :notice,
      :default_message

    it_behaves_like 'a helper which yields message of kind', :default_klass,
      :notice,
      :default_message
  end

  context '#each' do
    let(:nonpersistent_message) { nonpersistent_message_klass.alert(default_message) }
    let(:persistent_message) { persistent_message_klass.alert(default_message) }

    it 'records all messages' do
      subject << nonpersistent_message
      subject << persistent_message
      expect(first_message).to match(nonpersistent_message.message)
      expect(second_message).to match(persistent_message.message)
    end

    it 'does not allow duplicate messages of same type / level' do
      expect(subject.messages).to be_empty
      subject << persistent_message
      subject << persistent_message
      subject << nonpersistent_message
      subject << nonpersistent_message
      expect(subject.messages.size).to eq(2)
    end

    it 'iterates through all messages and persists the persistent messages' do
      subject << nonpersistent_message
      subject << persistent_message
      read_messages = []
      subject.each_message do |message|
        read_messages << message
      end
      expect(read_messages).to include(nonpersistent_message)
      expect(read_messages).to include(persistent_message)
      expect(subject.messages.size).to eq(1)
      expect(first_message).to eq(persistent_message)
    end
  end

  context '#serialization' do
    let(:nonpersistent_message) { nonpersistent_message_klass.alert(default_message) }
    let(:persistent_message) { persistent_message_klass.alert(default_message) }

    let(:expected_json) do
      {
        "locale" => "en-US",
        "messages" => [
          {
            "i18n_params" => { "raise" => true },
            "level" => "alert",
            "translation" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce id lobortis tortor. Nam cursus pharetra purus non elementum. Sed eu libero leo. Aliquam eget justo vel odio consectetur facilisis id a sapien. Duis pulvinar tincidunt suscipit. Quisque volutpat justo vitae fringilla lacinia. Aenean semper, nulla at mattis sagittis, purus felis aliquet lorem, sit amet suscipit dolor elit nec tellus. Pellentesque interdum nulla maximus massa elementum, at posuere augue scelerisque.",
            "class" => "nonpersistent"
          },
          {
            "i18n_params" => { "raise" => true },
            "level" => "alert",
            "translation" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce id lobortis tortor. Nam cursus pharetra purus non elementum. Sed eu libero leo. Aliquam eget justo vel odio consectetur facilisis id a sapien. Duis pulvinar tincidunt suscipit. Quisque volutpat justo vitae fringilla lacinia. Aenean semper, nulla at mattis sagittis, purus felis aliquet lorem, sit amet suscipit dolor elit nec tellus. Pellentesque interdum nulla maximus massa elementum, at posuere augue scelerisque.",
            "class" => "persistent"
          }
        ]
      }.to_json
    end

    it 'serializes itself and messages' do
      subject << nonpersistent_message
      subject << persistent_message
      expect(subject.to_session).to eq(expected_json)
    end

    it 'deserializes itself and messages' do
      subject << nonpersistent_message
      subject << persistent_message
      deserialized_instance = subject.class.from_session(expected_json)
      expect(deserialized_instance.messages.size).to eq(2)
      expect(deserialized_instance.messages.first.persistent?).to be_falsy
      expect(deserialized_instance.messages.last.persistent?).to be_truthy
    end
  end
end
