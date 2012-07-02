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
    offset = self.class.send_at_offset
    self.class.after_blocks.map do |b|
      t = starting_time + b[:offset]
      if offset and b[:offset] >= 1.day
        t = t.beginning_of_day + offset[0].hours + offset[1].minutes
      end
      t
    end
  end

  module ClassMethods
    def send_at_offset ; @send_at_offset ; end

    def after_blocks
      @after_blocks ||= []
    end

    def after(offset, &block)
      after_blocks << { offset: offset }
    end

    def send_at(offset_array)
      @send_at_offset = offset_array
    end

  end

end
