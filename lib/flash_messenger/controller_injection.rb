module FlashMessenger
  module ControllerInjection
    extend ActiveSupport::Concern

    included do
      around_filter :synchronize_flash_messenger_session

      def flash_messenger
        serialize_flash_messenger
        deserialize_flash_messenger
      end

      protected

      def clear_flash_messenger_session
        @flash_messenger = nil
        session.delete(:flash_messenger)
        initialize_flash_messenger
      end

      private

      def synchronize_flash_messenger_session(&block)
        deserialize_flash_messenger
        block.call
        serialize_flash_messenger
      end

      def initialize_flash_messenger
        @flash_messenger ||= FlashMessenger.new
        session[:flash_messenger] ||= @flash_messenger.to_session
      end

      def serialize_flash_messenger
        initialize_flash_messenger
        session[:flash_messenger] = @flash_messenger.to_session
      end

      def deserialize_flash_messenger
        initialize_flash_messenger
        @flash_messenger = FlashMessenger.from_session(session[:flash_messenger])
      end
    end
  end
end
