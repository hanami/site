---
title: "dry-system 0.9 released with new plugins"
date: 2018-01-05 12:00 UTC
author: Peter Solnica
---

Hello in 2018! We're starting the year with a couple of new releases, including dry-system 0.9 which comes with support for dry-monitor's notifications and a new plugin API. There are already six built-in plugins that you can enable, and it's very easy to write your own. This release is also sort of a clean up, as a bunch of features that we previously had in dry-web, have been ported to dry-system's plugins.

## Logging support

You can now enable a default system logger by simply enabling `:logging` plugin, you can also configure log dir, level and provide your own logger class.

``` ruby
class App < Dry::System::Container
  use :logging
end

# default logger is registered as a standard object, so you can inject it via auto-injection
App[:logger]

# short-cut method is provided too, which is convenient in some cases
App.logger
```

## Monitoring

Another plugin is called `:monitoring` which allows you to enable object monitoring, which is built on top of dry-monitor's instrumentation API. Let's say you have an object registered under `"users.operations.create"`, and you'd like to add additional logging:

``` ruby
class App < Dry::System::Container
  use :logging
  use :monitoring
end

App.monitor("users.operations.create") do |event|
  App.logger.debug "user created: #{event.payload} in #{event[:time]}ms"
end
```

You can also provide specific methods that should be monitored, let's say we're only interested in `#call` method:

``` ruby
App.monitor("users.operations.create", methods: %i[call]) do |event|
  App.logger.debug "user created: #{event.payload} in #{event[:time]}ms"
end
```

## Setting environment

Environment can now be set in a non-web systems too. Previously this was only possible in dry-web, now any ruby app based on dry-system can use this configuration setting via `:env` plugin:

``` ruby
class App < Dry::System::Container
  use :env

  configure do |config|
    config.env = :staging
  end
end
```

You can provide environment inferrer, which is probably something you want to do, here's how dry-web sets up its environment:

``` ruby
module Dry
  module Web
    class Container < Dry::System::Container
      use :env, inferrer: -> { ENV.fetch("RACK_ENV", :development).to_sym }
    end
  end
end
```

## Experimental bootsnap support

dry-system is already pretty fast, but in a really big apps, it can take over 2 seconds to boot. You can now speed it up significantly by using `:bootsnap` plugin, which simply configures bootsnap for you:

``` ruby
class App < Dry::System::Container
  use :bootsnap # that's it
end
```

We've noticed a ~30% speed boost during booting the entire app, unfortunately there are some problems with bootsnap + byebug, so it is now recommended to turn it off if you're debugging something.

## Plans for 1.0.0

We're finally close to 1.0.0! The only thing that's left to do is to look into booting process and see if we can speed things up. New features in 0.9 release also need a little bit of time, so that we can be confident there are no bugs and things work as expected. That's why it'd be really good if you give it a shot and report any issues you may encounter! Some of the features, like monitoring, depend on dry-monitor and the new dry-events gem, which means we also want to get them to 1.0.0 state.

For more information see:

- dry-system 0.9 [CHANGELOG](https://github.com/dry-rb/dry-system/blob/main/CHANGELOG.md#090---2018-01-02)
- dry-monitor 0.1 [CHANGELOG](https://github.com/dry-rb/dry-monitor/blob/main/CHANGELOG.md)
- dry-events 0.1 - this is a new gem which powers dry-monitor's notifications, checkout its [introduction documentation](/gems/dry-events)
