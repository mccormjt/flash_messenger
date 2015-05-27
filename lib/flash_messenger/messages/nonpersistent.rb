module FlashMessenger
  module Messages
    class Nonpersistent < Base
      def persistent?
        false
      end
    end
  end
end
