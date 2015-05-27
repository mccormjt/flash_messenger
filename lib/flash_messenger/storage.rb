module FlashMessenger
  class Storage
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::AttributeMethods
    extend ActiveModel::Naming

    attr_accessor :locale, :messages

    def initialize(locale = DEFAULT_LOCALE.to_sym)
      @locale, @messages = locale.to_sym, []
    end

    def <<(message)
      return unless message.is_a?(Messages::Base)
      return if @messages.any? { |i| message.eql?(i) }
      @messages << message
    end

    def each_message(&block)
      read_messages = []
      I18n.with_locale(@locale) do
        @messages.each do |message|
          block.call(message) if block_given?
          read_messages << message unless message.persistent?
        end
      end
      read_messages.each { |i| @messages.delete(i) }
    end

    def delete(message_or_translation)
      matcher = /#{message_or_translation}/
      @messages.delete_if do |message|
        message.to_s =~ matcher ||
          message.translation =~ matcher
      end
    end

    #
    # Message Helpers (by level)
    #

    def alerts
      @messages.select(&:alert?)
    end

    def errors
      @messages.select(&:error?)
    end

    def notices
      @messages.select(&:notice?)
    end

    def infos
      @messages.select(&:info?)
    end

    def alert(msg, klass = DEFAULT_MESSAGE_KLASS, **i18n_params)
      add(klass, :alert, msg, **i18n_params)
    end

    def error(msg, klass = DEFAULT_MESSAGE_KLASS, **i18n_params)
      add(klass, :error, msg, **i18n_params)
    end

    def info(msg, klass = DEFAULT_MESSAGE_KLASS, **i18n_params)
      add(klass, :info, msg, **i18n_params)
    end

    def notice(msg, klass = DEFAULT_MESSAGE_KLASS, **i18n_params)
      add(klass, :notice, msg, **i18n_params)
    end

    def add(klass, level, msg, **i18n_params)
      classify(klass).send(level, msg, **i18n_params).tap do |instance|
        self.<< instance
      end
    end

    #
    # Serialization Helpers
    #

    def from_json(json, include_root = include_root_in_json)
      super.tap do |instance|
        instance.messages = instance.messages.collect do |m|
          m.is_a?(Hash) ? classify(m['class']).from_session(m.to_json) : m
        end
      end
    end

    def serializable_hash
      super.tap do |instance|
        instance['messages'].map!(&:serializable_hash)
      end
    end

    def to_session
      serializable_hash.to_json
    end

    def self.from_session(json)
      new.from_json(json, false)
    end

    #
    # Required Serialization Interface Methods
    #

    attribute_method_suffix '_contrived?'
    attribute_method_prefix 'clear_'
    define_attribute_methods :locale, :messages

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def attributes
      instance_values
    end

    private

    def attribute_contrived?(attr)
      true
    end

    def clear_attribute(attr)
      send("#{attr}=", nil)
    end

    # Normalize :persistent / :nonpersistent to actual class reference
    def classify(name)
      return name unless name.is_a?(String) || name.is_a?(Symbol)
      "::FlashMessenger::Messages::#{name.to_s.classify}".safe_constantize
    end
  end
end
