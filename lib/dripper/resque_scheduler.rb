module Dripper
  module ResqueScheduler
    def self.included(klass)
      klass.send :include, Dripper
      klass.send :include, InstanceMethods
    end

    module InstanceMethods

      def enqueue(time)
        Resque.enqueue_at(time, self.class, { id: @instance.id })
      end

    end
  end
end
