---
title: "dry-monads 1.0 released"
date: 2018-06-26 12:00 UTC
author: Nikita Shilnikov
---

Today dry-monads [reaches 1.0](https://github.com/dry-rb/dry-monads/releases/tag/v1.0.0)! It started as a dependency replacement for the [Kleisli](https://github.com/txus/kleisli) gem in `dry-transaction` and `dry-types`. Later, more common monads were added, as well as support for `do` notation, which evaporates most of the boilerplate introduced by monads. Since the `dry-*` gems follow [semantic versioning](https://semver.org/spec/v2.0.0.html), this means you can consider the dry-monads API to be stable, making the gem more "production-ready". Let us show how monads can be useful in day-to-day ruby code.

## Result

`Result` is the most widely used monad from dry-monads so far. It represents a possibly unsuccessful computation. A trivial example:

```ruby
require 'dry/monads/result'

class Divide
  include Dry::Monads::Result::Mixin

  def call(x, y)
    if !y.zero?
      Success(x / y)
    else
      Failure(:division_by_zero)
    end
  end
end
```

`Result::Mixin` adds two constructors named `Success(...)` and `Failure(...)` so that you can separate the happy path from errors.

Suppose we have another math operation, square root:

```ruby
require 'dry/monads/result'

class Sqrt
  include Dry::Monads::Result::Mixin

  def call(x)
    if !x.negative?
      Success(Math.sqrt(x))
    else
      Failure(:negative_number)
    end
  end
end
```

Now, as with other monads, we can use `bind` for composition:

```ruby
class DivideThenRoot
  def divide
    Divide.new
  end

  def sqrt
    Sqrt.new
  end

  def call(x, y)
    divide.(x, y).bind(sqrt)
  end
end
```

```ruby
op = DivideThenRoot.new
op.(1.0, 2.0) # => Success(0.7071067811865476)
op.(1.0, 0.0) # => Failure(:division_by_zero)
op.(-1.0, 2.0) # => Failure(:negative_number)
```

`DivideThenRoot` can be composed with other objects or methods returning `Result`s in a similar manner. In the end, you can use [`dry-matcher`](/gems/dry-matcher/0.8/result-matcher) for processing the result (or use the `Result`'s [API](/gems/dry-monads/1.0/result) for it).

Real-life code looks the same in general but usually combines more operations together. Here it can become tedious to use `bind` and `fmap` directly. This is why we added `do` notation in the 1.0 release.

## Do notation

The name "do" comes from Haskell, where it's a reserved word for a block of code that uses monads to compose results of several operations. We don't have first-class support for it in Ruby, but it's quite possible to emulate it using blocks. Here's a typical piece of code written with `do`:


```ruby
require 'dry/monads/do'
require 'dry/monads/result'

class CreateAccount
  include Dry::Monads::Result::Mixin
  include Dry::Monads::Do

  def call(params)
    values = yield validate(params)
    owner = yield create_owner(values[:user])
    account = yield create_account(values[:account])

    yield create_subscription(account, owner)

    Success(account)
  end

  # ...
end
```

Here it's implied that the `validate`, `create_owner`, `create_account`, and `create_subscription` methods all return `Result`s. `yield` takes a `Result` value and either unwraps it if it's a `Success`, or interrupts the execution and immediately returns the `Failure` from `call`. With `do` it's extremely easy to combine results of different operations no matter the order in which they're called. This is a major step forward to making monads practically useful in Ruby.

## Task

Another highlight from the release is the `Task` monad. Backed by [`concurrent-ruby`](https://github.com/ruby-concurrency/concurrent-ruby), a battle-tested concurrency gem, `Task` can be used for composing asynchronous computations. Essentially, it's a [Promise](https://ruby-concurrency.github.io/concurrent-ruby/main/Concurrent/Promises.html) with a dry-monads-compatible interface.

```ruby
require 'dry/monads/task'
require 'dry/monads/do'

class CreateUser
  include Dry::Monads::Task::Mixin
  include Dry::Monads::Do

  def call(email, name)
    # Run two concurrent requests, wait for both to finish using Do
    yield validate_email(email), validate_name(name)

    create_user(email, name)
  end

  def validate_email(email)
    # Ruby 2.5+ syntax
    Task[:io] {
      # async email check, e.g. with an http request
    }
  end

  def validate_name(name)
    Task[:io] {
      # async name check
    }
  end

  def create_user(email, name)
    Task[:io] {
      # async create
    }
  end
end
```

## Still Ruby

Despite using concepts borrowed from other languages, dry-monads stays as much idiomatic to Ruby as possible. We have no plans to turn it into Haskell. Yet.

## Maturity

The gem is pretty much complete, and has been used in production for more than two years. We don't expect any major changes to the API, since the scope of monads, in general, is limited. This means any integration code will most likely be somewhere else.

## Acknowledgements

dry-monads is a [combined effort](https://github.com/dry-rb/dry-monads/graphs/contributors?type=a) of more than a dozen people. Thank you all for your work and feedback, it is much appreciated!
