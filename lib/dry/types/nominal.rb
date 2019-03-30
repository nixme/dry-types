require 'dry/core/deprecations'
require 'dry/types/builder'
require 'dry/types/result'
require 'dry/types/options'

module Dry
  module Types
    class Nominal
      include Type
      include Options
      include Builder
      include Printable
      include Dry::Equalizer(:primitive, :options, :meta, inspect: false)

      # @return [Class]
      attr_reader :primitive

      # @param [Class] primitive
      # @return [Type]
      def self.[](primitive)
        if primitive == ::Array
          Types::Array
        elsif primitive == ::Hash
          Types::Hash
        else
          self
        end
      end

      # @param [Type,Class] primitive
      # @param [Hash] options
      def initialize(primitive, **options)
        super
        @primitive = primitive
        freeze
      end

      # @return [String]
      def name
        primitive.name
      end

      # @return [false]
      def default?
        false
      end

      # @return [false]
      def constrained?
        false
      end

      # @return [false]
      def optional?
        false
      end

      # @param [BasicObject] input
      # @return [BasicObject]
      def call(input)
        input
      end
      alias_method :[], :call

      # @param [Object] input
      # @param [#call,nil] block
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Result,Logic::Result] when a block is not provided
      # @return [nil] otherwise
      def try(input, &block)
        success(input)
      end

      # @param (see Dry::Types::Success#initialize)
      # @return [Result::Success]
      def success(input)
        Result::Success.new(input)
      end

      # @param (see Failure#initialize)
      # @return [Result::Failure]
      def failure(input, error)
        Result::Failure.new(input, CoercionError[error])
      end

      # Checks whether value is of a #primitive class
      # @param [Object] value
      # @return [Boolean]
      def primitive?(value)
        value.is_a?(primitive)
      end

      def valid?(_)
        true
      end
      alias_method :===, :valid?

      def coerce(input)
        if primitive?(input)
          input
        else
          raise ConstraintError.new(
            "#{input.inspect} must be an instance of #{primitive}"
          )
        end
      end

      # Return AST representation of a type nominal
      #
      # @api public
      #
      # @return [Array]
      def to_ast(meta: true)
        [:nominal, [primitive, meta ? self.meta : EMPTY_HASH]]
      end
    end

    extend Dry::Core::Deprecations[:'dry-types']
    Definition = Nominal
    deprecate_constant(:Definition, message: "Nominal")
  end
end

require 'dry/types/array'
require 'dry/types/hash'
require 'dry/types/map'
