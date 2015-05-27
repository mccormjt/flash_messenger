module FlashMessenger
  module Messages
    class Base
      include ActiveModel::Model
      include ActiveModel::Serializers::JSON
      include ActiveModel::AttributeMethods
      extend ActiveModel::Naming

      attr_accessor :i18n_params, :level, :translation

      def initialize(level, translation, **i18n_params)
        @i18n_params, @level, @translation = i18n_params, level, translation
      end

      # Normalize hash and force :raise so we can catch exceptions
      def i18n_params
        @i18n_params[:raise] = true
        @i18n_params.sort.to_h
      end

      def i18n_params=(params)
        @i18n_params = Hash[params.map{ |k, v| [k.to_sym, v] }]
      end

      def level
        @level.to_sym
      end

      def message
        I18n.translate(self.translation, **self.i18n_params)
      rescue I18n::MissingTranslationData
        return self.translation.join('.') if self.translation.is_a?(Array)
        self.translation
      # rescue I18n::MissingInterpolationArgument
        # TODO
      end

      def to_s
        self.message.strip
      end

      #
      # Overridden Comparison Operators
      #

      def <=>(other)
        return (self.message <=> other) if other.is_a?(String)
        return nil unless other.is_a?(self.class)
        my_values = [self.message, self.level, self.class_name]
        other_values = [other.message, other.level, self.class_name]
        (my_values <=> other_values)
      rescue NoMethodError
        nil
      end

      def eql?(other)
        (self.<=> other) == 0
      end

      def match?(other)
        if other.is_a?(Base)
          us = "#{self.class_name}, #{self.level}, #{self.message}"
          them = "#{self.class_name}, #{self.level}, #{self.message}"
          us =~ them
        elsif other.is_a?(String)
          self.to_s =~ other
        end
        nil
      end

      alias_method :==, :eql?

      #
      # Message Interface Definitions
      #

      def persistent?
        raise NotImplementedError
      end

      #
      # Message Helpers (by level)
      #

      def alert?
        @level == :alert
      end

      def error?
        @level == :error
      end

      def info?
        @level == :info
      end

      def notice?
        @level == :notice
      end

      def self.alert(message, **i18n_params)
        new(:alert, message, **i18n_params)
      end

      def self.error(message, **i18n_params)
        new(:error, message, **i18n_params)
      end

      def self.info(message, **i18n_params)
        new(:info, message, **i18n_params)
      end

      def self.notice(message, **i18n_params)
        new(:notice, message, **i18n_params)
      end

      def class_name
        self.class.model_name.element
      end

      def self.class_name
        model_name.element
      end

      #
      # Serialization Helpers
      #

      def from_json(json, include_root=include_root_in_json)
        super(JSON.parse(json).tap { |this| this.delete('class') }.to_json)
      end

      def serializable_hash(options = {})
        super.merge({ 'class' => self.class_name })
      end

      def to_session
        serializable_hash.to_json
      end

      def self.from_session(json)
        new(:stub, nil).from_json(json, false)
      end

      #
      # Required Serialization Interface Methods
      #

      attribute_method_suffix '_contrived?'
      attribute_method_prefix 'clear_'
      define_attribute_methods :i18n_params, :level, :translation

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
    end
  end
end
