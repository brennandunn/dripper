Dripper
=======

### Description

Dripper is a lightweight library that makes it easy to setup a series of scheduled events to be fired off. It was originally written to help me setup [drip marketing campaigns](http://en.wikipedia.org/wiki/Drip_marketing) for [Planscope](https://planscope.io).

### Usage

To install

  gem 'dripper'

Define a class, and include a Dripper adapter (at the moment, only ResqueScheduler is supported)

  class UserDrip
    include Dripper::ResqueScheduler
  end

Dripper needs a few things defined in order to work properly. First, a series of blocks to be executed.

  after 5.minutes do |user|
    UserMailer.welcome(user).deliver!
  end

  after 10.days do |user|
    UserMailer.trial_expiring_soon(user).deliver!
  end

No presumptions are made about how you go about finding an instance to yield into an after block, so define a class level lookup method:

  def self.fetch_instance(options={})
    User.find(options[:id])
  end

By default Dripper will fire a block after the offset you provide has elapsed, but sending emails in the middle of the night isn't always ideal. By specifying the offset in hours and minutes (relative to midnight), you can make sure your messages are sent at the ideal time.

  send_at [9, 0] # send at 9am

You can also have Dripper not perform blocks on weekends.

  send_at [15, 0], weekends: false

If you *don't* want certain blocks to be fired, the only way to do that now is to add the right conditions in your blocks. A good use case would be sending out "come back! we miss you!" emails - it's likely that you don't want those sent to paying customers.

### Dependencies

At the moment, ResqueScheduler is the only job scheduler supported. However, it would be pretty trivial to fork and add in a hook to your own scheduler (hint hint!)

Additionally, ActiveSupport is required.

### Contributing to Dripper
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2012 Brennan Dunn. See LICENSE.txt for
further details.

