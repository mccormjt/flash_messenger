require 'flash_messenger/storage'
require 'flash_messenger/messages/base'
require 'flash_messenger/messages/nonpersistent'
require 'flash_messenger/messages/persistent'

module FlashMessenger
  DEFAULT_MESSAGE_KLASS = Messages::Nonpersistent

  module Nonpersistent
    class << self
      delegate :alert, :error, :info, :notice, :new, to: DEFAULT_MESSAGE_KLASS
    end
  end

  module Persistent
    class << self
      delegate :alert, :error, :info, :notice, :new, to: Messages::Persistent
    end
  end

  class << self
    delegate :from_session, :new, :to_session, to: Storage
    delegate :alert, :error, :info, :notice, to: DEFAULT_MESSAGE_KLASS
  end
end
