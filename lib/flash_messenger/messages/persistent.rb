module FlashMessenger
  module Messages
    class Persistent < Base
      def persistent?
        true
      end
    end
  end
end
