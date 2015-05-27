require 'flash_messenger/engine'
require 'flash_messenger/controller_injection'

module FlashMessenger
  DEFAULT_LOCALE = :'en-US'
  # Rails.configuration.tap do |c|
  #   DEFAULT_LOCALE = c.flash_messenger.default_locale || c.i18n.default_locale
  # end
end
