require 'active_support/all'

module Dripper

  def self.included(klass)
    klass.extend ClassMethods
  end

  def initialize(instance)
    raise ArgumentError, "The object must respond to #id" unless instance.respond_to?(:id)
    @instance = instance
  end

  def starting_time
    @instance.created_at
  end

  def scheduled_times
    self.class.after_blocks.map { |b| starting_time + b[:offset] }
  end

  module ClassMethods

    def after_blocks
      @after_blocks ||= []
    end

    def after(offset, &block)
      after_blocks << { offset: offset }
    end

  end

end
