---
title: Introducing dry-system
date: 2016-08-15 12:00 UTC
author: Peter Solnica
---

We’re happy to announce the release of `dry-system` 0.5.0 (previously known as dry-component), which brings many internal API improvements, and better support for bootable components.

## Reasoning behind the project

One of the reasons building and maintaining applications is difficult is their complex nature. Even a single-file Sinatra web application is complex, as it relies on multiple *components*. Even Sinatra itself is a 3rd-party component, giving you the beautiful routing DSL. Since it’s Sinatra, you also happen to be using Rack, which is another component of your application. If you’re using Rack, you’re also using rack middlewares, each being a component. When you look at it this way, it is easy to see that the nature of a “simple” sinatra application is complex by definition - it’s something composed of multiple, connected components. This is also just the very base of your application. Chances are, you’re going to use a database, which will be handled by another 3rd party library, maybe some JSON serializer, or a template renderer - all these things become part of your application, and at the same time they are standalone, reusable components. Then when you start writing the actual code of your application, even if you don’t think about your code providing additional components to your application, this *is exactly what’s going on*. When you don’t think about your own code as something that provides standalone, reusable components that are used across your application, it’s unfortunately easy to trap yourself into a corner called “too much coupling”.

## Object dependencies

Every application is a system that consists of multiple components. Typically, many of these are provided by 3rd-party libraries. These components often need to undergo various configuration and initialization processes. Bundler solved the problem of gem dependencies, but how do we solve the problem of **object dependencies**?

If you’re used to how Rails works, this problem is seemingly nonexistent - Rails requires files automatically for you whenever you refer to a constant that is not yet defined. This is convenient, but it comes with a real danger - tight coupling. The result of this approach is that your application’s code crosses many boundaries (http layer, database, file system etc.) in an uncontrolled manner, and the moment when it becomes a visible problem is the moment when it’s often very difficult to refactor the code and reduce the coupling. This is **one of the main reasons** maintaining large Rails codebases is difficult.

Ruby is an object-oriented language, and one of the most powerful OO techniques is **object composition**. In order to easily reduce an application’s complexity, you encapsulate individual concerns in separate objects, and compose them into a system. When your application is a mixture of classes, modules *and* objects, and when dependencies between individual objects are not handled explicitly, things don’t usually go very well. Let’s fix this.

## Dependency Injection
Yes, the almost forbidden word in the Ruby community. If you think we don’t need DI in Ruby because in tests we can monkey-patch - please reconsider, DI’s purpose is not to help you with testing (although it’s a bonus side-effect!), its purpose is to **reduce coupling**. Furthermore, DI in Ruby is very simple. Look:

``` ruby
class UserRepo
  attr_reader :db

  def initialize(db)
    @db = db
  end
end

UserRepo.new(Sequel.connect('sqlite::memory'))
```

It would be great if nothing else was needed, but unfortunately there are a few things we still need to take care of:

* Something needs to know there’s a `UserRepo` class and its constructor accepts a database connection
* Something needs to know how and when `sequel` library needs to be required
* Something needs to know how to initialize a sequel connection
* Something needs to know how to *manage* a sequel connection

What is that *something* we’re talking about here?

## System with components
Finally, we get to talk about `dry-system`! In applications based on `dry-system`, we organize our code into a system that consists of multiple components. This is really what every application is, except we choose to make it very explicit. Furthermore, we use Dependency Injection, and class interfaces are used purely as object constructors (typically via the `.new` method). This means our system uses **objects** exclusively, which gives as a great advantage - object composition, something you cannot do with classes.

Such systems are loosely-coupled, they rely on abstractions, rather than concrete classes or modules, and 3rd party code is completely isolated from the application’s core logic. `dry-system` provides facilities to require files, set up `$LOAD_PATH` and **manage your application’s state**. This is done in a clear and explicit way, giving you complete control over your system. Big applications can be split into multiple sub-systems easily too.

## How does it work?

`dry-system` provides two main APIs - a container and a DI mixin. All you need to do is to define a system container:

``` ruby
# system/container.rb
class MyApp < Dry::System::Container
  load_paths!('lib')
end
```

Then, you can ask your system container to provide a DI mixin that you can use in your classes:

``` ruby
# system/import.rb
require_relative 'container'
Import = MyApp.injector
```

Then our previous example with `UserRepo` can become this:

``` ruby
require 'my_app/import'

class UserRepo
  include Import['persistence.db']
end
```

So, where does that `persistence.db` come from?

## Bootable components

In `dry-system` we have two types of components: ones that can be simply `require`’ed and the more complex ones that may need 3rd-party code, custom setup or even multiple lifecycle states.

Our `persistence.db` is a great example of such a complex component. It needs configuration, it needs 3rd-party code, and it’s **stateful**, so it has to be managed somehow.

In order to handle this type of component, `dry-system` provides a booting API. This is based on a convention that you put files under `%{root}/system/boot` directory, where you initialize components.

Here’s how we could configure Sequel:

``` ruby
# system/boot/persistence.rb
MyApp.finalize(:persistence) do |persistence|
  init do
    require 'sequel'
  end

  start do
    persistence.register('persistence.db', Sequel.connect(ENV['DB_URL']))
  end

  stop do
    db.close_connection
  end
end
```

This way we have a single place where our `persistence.db` component is being required and loaded. This comes with a great benefit of **being able to boot a component on demand**.

Let’s say you have a rake task which needs the `persistence.db` component (effectively a sequel connection). This is all you need to do:

``` ruby
require_relative 'system/container'

desc "do something with db"
task :db do
  MyApp.boot!(:persistence)
  # now you have access to MyApp['persistence.db']
end
```

There’s a significant benefit of this approach - the minimum amount of code is being required when you boot components on demand. Here’s a real-world effect:

```
% time bundle exec rake db:setup
bundle exec rake db:setup  0.73s user 0.16s system 98% cpu 0.899 total
```

This means we have **a sub-second boot time**, with no complex preloaders like Spring or Zeus. As you can imagine, you can easily leverage that for test environment, where individual test groups may only require small portion of your system, resulting in sub-second boot times and fast development cycles.

## Auto-registration

Convention-over-configuration is a great thing and we embrace it here too. Your application’s code can be automatically registered, and individual components are instantiated for you. The only thing you need to do is to configure an `auto_register` path:

``` ruby
# system/container.rb
class MyApp < Dry::System::Container
  configure do |config|
    config.auto_register = %w(lib)
  end

  load_paths!('lib')
end
```

Now if you put `UserRepo` class definition in `lib/user_repo.rb`, it will be automatically loaded and registered within the system container. This **reduces a lot of boilerplate code** related to object instantiation, you will quickly appreciate how clean your class definitions look like and that you can focus on core logic exclusively without bothering about object construction at all. Since classes specify their dependencies explicitly, it’s also easy to understand which components are being injected.

## Learn more!

You can check out a full-blown web application called [Berg](https://github.com/icelab/berg), which is based on `dry-system`. If you want to see something really basic - check out a [standalone example app](https://github.com/dry-rb/dry-system/tree/main/examples/standalone) with a full setup using examples from this article.

There’s also a [dedicated user documentation](/gems/dry-system) and [API documentation](https://rubydoc.info/gems/dry-system). You can already use `dry-system` via [dry-web-roda](https://github.com/dry-rb/dry-web-roda) and we’ll be working on support for Hanami and Rails soon too.

As always, there’s a lot to improve and we’ll continue to work on it. This release is a major improvement in terms of internal APIs as well as public-facing features, so we have a good foundation for future improvements. If you try it out and find any issues, please [report them](https://github.com/dry-rb/dry-system/issues).
