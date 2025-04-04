---
title: New releases of dry-types and dry-validation
date: 2016-03-31 12:00 UTC
author: Peter Solnica
---

What a busy week! New versions of [dry-types](http://dry-rb.org/gems/dry-types) and [dry-validation](http://dry-rb.org/gems/dry-types) have been released and there are really exciting new features awaiting for you. We're also very excited to see [Trailblazer](http://trailblazer.to) adopting some dry-rb libraries - Reform will soon support latest dry-validation, and Disposable has already replaced Virtus with dry-types for its coercion functionality.

## New dry-validation features

The major highlight of the new 0.7.3 dry-validation release is improved integration with dry-types, a feature that we haven't revealed until now. Both dry-validation and dry-types are based on the same foundational library called dry-logic. Validation rules and type constraints are handled by dry-logic, which means we can use constrained types to share common constraints between type definitions and validation schemas to reduce information duplication. This will DRY-up your code (see what I did there?).

Here's what it means in practice:

``` ruby
require 'dry-validation'
require 'dry-types'

module Types
  include Dry::Types.module

  Age = Strict::Int.constrained(gt: 18)
end

UserSchema = Dry::Validation.Form do
  key(:name).required
  key(:age).required(Types::Age)
end

UserSchema.(name: 'Jane', age: 17).messages
# { age: ["must be greater than 18"] }
```

This way you can encapsulate important constraints and completely avoid duplication.

We are not stopping here!

### Custom constructor types!

Another fantastic improvement is support for custom constructor types in validation schemas. You can now define types that can encapsulate custom coercion logic and dry-validation will infer an input processor from it and apply it to the input data before validation.

Simple example:

``` ruby
require 'dry-validation'
require 'dry-types'

module Types
  include Dry::Types.module

  module DataImport
    StrippedString = Strict::String.constructor { |value| value.to_s.strip }
  end
end

UserImport = Dry::Validation.Schema do
  configure { config.input_processor = :sanitizer }

  key(:name).required(Types::DataImport::StrippedString)
  key(:email).required(Types::DataImport::StrippedString)
end

UserSchema.(name: '   Jane  ', email: 'jane@doe.org  ').to_h
# { name: "Jane", email: "jane@doe.org" }
```

This is a clean way of encapsulating custom coercion or sanitization logic. Notice that your type objects are small and reusable. You can also use them manually anywhere in your application, e.g. `Types::DataImport::StrippedString[" foo "] # => "foo"`.

dry-validation infers both validation rules and value constructors from your types, notice that `Types::DataImport::StrippedString` is a strict string, which means a proper validation rule is set too:

``` ruby
UserSchema.(name: '   Jane  ', email: nil).messages
# { email: ["must be filled", "must be String"] }
```

### Applying external schemas conditionally

When defining a high-level rule, you can now delegate validation to an external schema. Why would you want to do that? Let's say you have a nested data structure, and parts of that structure should be validated using different schemas based on other values from that data structure. In example:

``` ruby
CreateCommandSchema = Dry::Validation.Schema do
  key(:name).required
  key(:email).required
end

UpdateCommandSchema = Dry::Validation.Schema do
  key(:id).required(:int?)
  key(:data).schema(CreateCommandSchema)
end

CommandSchema = Dry::Validation.Schema do
  key(:command).maybe(:str?, :inclusion?: %w(Create Update))
  key(:args).maybe(:hash?)

  rule(create_command: [:command, :args]) do |command, args|
    command.eql?('Create').then(args.schema(CreateCommandSchema))
  end

  rule(update_command: [:command, :args]) do |command, args|
    command.eql?('Update').then(args.schema(UpdateCommandSchema))
  end
end

CommandSchema.(command: 'Oops').messages.inspect
# { command: ["must be one of: Create, Update"], args: ["is missing"] }

CommandSchema.(
  command: 'Create', args: { name: 'Jane', email: nil }
).messages
# { args: { email: ["must be filled"] } }

CommandSchema.(
  command: 'Update', args: { id: 1, data: { name: nil, email: 'jane@doe.org' } }
).messages
# { data: { name: ["must be filled"] } }
```

Notice that our high-level rules explicitly define which values they rely on. It means we don't have to worry about validation rules from external schemas crashing due to invalid state. If `args` is `nil`, nothing will crash. Furthermore, if `command` is not one of the allowed values, we won't even bother trying to apply external schemas.

### New predicate: :number?

You can now specify that a value must be a number, in case of `Form` schemas a proper coercion is applied:

``` ruby
UserSchema = Dry::Validation.Form do
  key(:age).required(:number?, :int?)
end

UserSchema.(age: '1').to_h
# { age: 1 }

UserSchema.(age: 'one').messages
# { age: ["must be a number"] }

UserSchema.(age: '1.5').messages
# { age: ["must be an integer"] }
```

## New dry-types features

dry-types 0.7.0 focused on improving support for complex types and better exception messages. You can now specify complex types, like arrays or hashes, along with constraints.

Let's say you want to specify `Options` type which is an array with either strings or string pairs inside nested arrays:

``` ruby
require 'dry-types'

module Types
  include Dry::Types.module

  StringList = Strict::Array.member(Strict::String)
  StringPair = Strict::Array.member(Strict::String).constrained(size: 2)
  StringPairs = Strict::Array.member(StringPair)

  Options = StringList | StringPairs
end

Types::Options.call(["one", "two"])
# ["one", "two"]

Types::Options.call([["a", "one"], ["b", "two"]])
# [["a", "one"], ["b", "two"]]

Types::Options.call(["one", nil])
# Dry::Types::ConstraintError

Types::Options.call([["a", "one"], ["b"]])
# Dry::Types::ConstraintError
```

Exception messages have been improved too; however, they're still a work in progress, and complex types like in the previous example still need some work.

Here's what you'd get if a simple constraint was violated:

``` ruby
Password = Types::Strict::String.constrained(size: 10)

Password["foo"]
# Dry::Types::ConstraintError: "foo" violates constraints (size?(10) failed)
```

## Enjoy!

We hope you'll find new features useful. In case of any issues, please report them on GitHub or chat with us on [Zulip](https://dry-rb.zulipchat.com).

If you want to use new features, just add latest versions to your Gemfile:

``` ruby
gem "dry-types", "~> 0.7.0"
gem "dry-validation", "~> 0.7.3"
```

Detailed CHANGELOGs:

- dry-validation [v0.7.2](https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md#v072-2016-03-28) and quick follow-up [v0.7.3](https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md#v073-2016-03-30)
- dry-types [v0.7.0](https://github.com/dry-rb/dry-types/blob/main/CHANGELOG.md#v070-2016-03-30)
