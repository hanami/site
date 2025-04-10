---
title: "dry-validation 1.0.0 released"
date: 2019-06-10 12:00 UTC
author: Peter Solnica
---

We're very happy to announce the release of dry-validation 1.0.0!

This is a big release: it includes a rewritten schema DSL, released as [dry-schema](/gems/dry-schema), and a completely redesigned validation system. If you're interested to know the reasoning behind these changes, please refer to the "[Plans for dry-validation + dry-schema (a new gem!)](https://discourse.dry-rb.org/t/plans-for-dry-validation-dry-schema-a-new-gem/215)" post on our forum. Yes, it's from February 2017, this took a while, but it was totally worth the wait. Continue reading to see why.

## New-old schema DSL

The schema DSL has been rewritten from scratch and not only did it fix dozens of known issues, it also introduced a couple of new features. That said, some complex features that didn't fit anymore were removed. In dry-validation 1.0.0, the schema DSL is delegated to dry-schema and you can still define 3 types of schemas:

1. `schema` - a plain schema that does not perform any coercions
1. `params` - a schema with coercions optimized for HTTP params
1. `json` - a schema with coercions optimized for JSON

The syntax for defining keys with validations is almost identicial to the one you know from previous versions of dry-validation. However, there's a big conceptual difference between those earlier versions and how dry-validation 1.0.0 is intended to be used now.

## Contracts with rules

We have a completely new concept called `Contract` that allows you to define a schema and **domain validation rules**. The new rule system is completely decoupled from the schema validation, but it's still **type-safe**, which means that **when you define a rule you can assume the types of the values are correct**. This removes the need to perform any additional checks in validation rules and you are going to love this.

Here's a simple example where we define a contract for a new user data:

```ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:age).filled(:integer)
  end

  rule(:name) do
    key.failure("is too short") if value.length < 3
  end

  rule(:age) do
    key.failure("you must be at least 13 years old") if value < 13
  end
end
```

If you are familiar with the old version, your immediate reaction might be "oh that's more code, why not just define these checks in the schema?" That's a good question to ask! It's still possible to use all the known predicates so, technically speaking, you could perform these checks via the schema **but** it's not recommended. Starting with 1.0.0, we're moving to a new way of thinking about validations by splitting them into basic structural and type checks handled by schemas and domain validations handled by contracts and their rules. This is a good way of separating concerns to make your code cleaner, simpler and more reusable.

If the amount of code you need to write is a concern, don't worry, because we have [a new macro system](/gems/dry-validation/1.0/macros) in place to DRY things up.

## Improved messages

One of the biggest limitations in the previous version was the way you could provide custom error messages. Starting from 1.0.0, you have complete control over this process. You can now:

- Provide a message as a plain string, e.g. `key.failure("oops this is wrong")`
- Provide a message using a locale identifier, e.g. `key.failure(:invalid)`
- Pass extra data when using locales, e.g. `key.failure(:invalid, more: "info", goes: "here")`
- Pass additional metadata in addition to the message text, e.g. `key.failure(text: "oops this is wrong", code: :red)`

On top of this, we still support localized backends using plain `YAML` or `I18n` gem.

## Base messages

Another nice improvement is support for **base messages**. This means you can provide a message that will be associated with the whole input, instead of a specific key.

Here's an example:

``` ruby
class EventContract < Dry::Validation::Contract
  option :today, default: Date.method(:today)

  params do
    required(:start_date).value(:date)
    required(:end_date).value(:date)
  end

  rule do
    if today.saturday? || today.sunday?
      base.failure('creating events is allowed only on weekdays')
    end
  end
end
```

Now we can access base errors (assuming it's a weekend):

``` ruby
contract = EventContract.new

contract.call(start_date: Date.today+1, end_date: Date.today+2).errors
# #<Dry::Validation::MessageSet
#   messages=[
#     #<Dry::Validation::Message text="creating events is allowed only on weekdays" path=[nil] meta={}>
#   ]
#   options={}
# >
```

## Macros

As mentioned above, you can use the new macro system to reduce code duplication. Currently, there's only one built-in macro, called `:acceptance`, but we'll be adding more.

Here's an example how you could use the `:acceptance` macro:

``` ruby
class NewUserContract < Dry::Validation::Contract
  schema do
    required(:email).filled(:string)
    required(:terms).filled(:bool)
  end

  rule(:terms).validate(:acceptance)
end

contract = NewUserContract.new

contract.call(email: "jane@doe.org", terms: "false").errors.to_h
# => {:terms=>["must accept terms"]}

contract.call(email: "jane@doe.org", terms: "true").errors.to_h
# => {}
```

Defining your own macros is very simple and you're encouraged to do so. Let's say we want to encapsulate checking if a string is of a minimum length, here's how you could do it with a macro:

``` ruby
class ApplicationContract < Dry::Validation::Contract
  register_macro(:min_length) do |macro:|
    key.failure("is too short") if value.length < macro.args[0]
  end
end
```

Now we can use our `:min_length` macro in other contract classes:

```ruby
class NewUserContract < ApplicationContract
  schema do
    required(:email).filled(:string)
    required(:password).filled(:string)
  end

  rule(:password).validate(min_length: 12)
end

contract = NewUserContract.new

contract.call(email: "jane@doe.org", terms: "false", password: "secret").errors.to_h
# => {:password=>["is too short"]}
```

The posibilities are endless and I'm sure we'll soon have a nice collection of macros either built into the main gem or provided as an extension.

## Improved validation of array elements

Validating array elements can be tricky business, but it's become nice and simple in dry-validation 1.0.0. It works using the same mechanism as other value types - an array element will not be checked by a rule unless the corresponding schema checks passed.

To validate array elements, use `Rule#each`:

``` ruby
class NewSongContract < Dry::Validation::Contract
  params do
    required(:artist).filled(:string)
    required(:title).filled(:string)
    required(:tags).array(:string)
  end

  rule(:tags).each do
    key.failure("tag length must be at least 3") if value.length < 3
  end
end
```

Now let's see it in action:


```ruby
contract = NewSongContract.new

contract.(artist: "Queen", title: "Bohemian Rhapsody", tags: ["rock", 123, "ab"]).errors.to_h
# => {:tags=>{1=>["must be a string"], 2=>["tag length must be at least 3"]}
```

Notice that our rule did not crash on `123` value even though `Integer` does not implement `length` - instead, we got a nice error that the second element must be a string. This is how type safety in rules work.

## Upgrading from dry-validation 0.x

Please refer to the comprehensive guide "[dry-rb 1.0: upgrading validations, types and schemas](https://www.morozov.is/2019/05/31/upgrading-dry-gems.html)," written by Igor Morozov. He's done a terrific job explaining the process.

Additionally, check out:

- dry-validation 1.0.0 [CHANGELOG](https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md#v100-2019-06-10)
- dry-types 1.0.0 [CHANGELOG](https://github.com/dry-rb/dry-types/blob/main/CHANGELOG.md#v100-2019-04-23)
- dry-schema 1.0.0 [CHANGELOG](https://github.com/dry-rb/dry-schema/blob/main/CHANGELOG.md)s

If you need help with upgrading, **please do not hesitate to ask questions either on our [discussion forum](https://discourse.dry-rb.org) or [community chat](https://dry-rb.zulipchat.com)**.

## Thank you

Thank you to all the contributors and early adopters who helped us shape dry-validation. This has been a big effort and we're very happy with the results. Please check it out and let us know what you think!
