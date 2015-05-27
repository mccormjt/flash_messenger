require 'pry'
require 'spec_helper'

RSpec.describe FlashMessenger, js: true do
  subject { FlashMessenger }

  let(:nonpersistent_message_klass) { FlashMessenger::Messages::Nonpersistent }
  let(:persistent_message_klass) { FlashMessenger::Messages::Persistent }

  let(:default_klass) { FlashMessenger::DEFAULT_MESSAGE_KLASS }
  let(:default_translation) { 'development.lorem_ipsum_1' }
  let(:default_message) { I18n.t(default_translation) }
  let(:default_level) { :notice }
  let(:default_params) { { test: 'foo' } }

  context '#new' do
    it 'returns a new FlashMessenger::Storage object' do
      expect(subject.new).to be_a(FlashMessenger::Storage)
    end

    it 'with an empty message array' do
      expect(subject.new.messages).to be_a(Array)
      expect(subject.new.messages).to be_empty
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

  context 'during user session' do
    let(:flash_messenger) { FlashMessenger.new }

    def cycle_messages(flash_messenger)
      flash_messenger.each_message { |i| puts i }
    end

    it 'persists :persistent messages' do
      flash_messenger.error "It is currently #{DateTime.now}.", :persistent

      expect { cycle_messages(flash_messenger) }.not_to \
        change { flash_messenger.messages.size }
    end

    it 'does not persist :nonpersistent messages' do
      flash_messenger.error "It is currently #{DateTime.now}."

      expect { cycle_messages(flash_messenger) }.to \
        change { flash_messenger.messages.size }.by(-1)
    end
  end
end
