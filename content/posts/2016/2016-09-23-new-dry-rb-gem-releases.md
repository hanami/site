---
title: New gem releases
date: 2016-09-23 12:00 UTC
author: Peter Solnica
---

We’re happy to announce not one, but four big releases today - dry-validation 0.10, dry-types 0.9, dry-logic 0.4 and the new dry-struct gem! These releases are focused on bug fixes, performance improvements, internal refactorings, and new features, too.

There are a couple of breaking changes, please refer to the changelogs for detailed information:

* dry-validation 0.10.0 - [CHANGELOG](https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md#v010-2016-09-21)
* dry-types 0.9.0 - [CHANGELOG](https://github.com/dry-rb/dry-types/blob/main/CHANGELOG.md#v010-2016-09-21)
* dry-struct 0.1.0 - [CHANGELOG](https://github.com/dry-rb/dry-struct/blob/main/CHANGELOG.md#v010-2016-09-21)
* dry-logic 0.4.0 - [CHANGELOG](https://github.com/dry-rb/dry-logic/blob/main/CHANGELOG.md#v010-2016-09-21)

## dry-validation 0.10

This version ships with an improved support for messages, with errors and hints generated separately, as well as a big performance boost. There are also a couple of new features that you should find useful.

### Errors & Hints
The `Result#messages` interface works the same as before, and in addition to that we have `Result#errors` and `Result#hints`. Here’s how you can use them:

``` ruby
UserSchema = Dry::Validation.Form do
  required(:login).filled(size?: 3..64)
  required(:age).filled(:int?, gt?: 18)
end

UserSchema.(login: '', age: 17).errors
# {:login=>["must be filled"], :age=>["must be greater than 18"]}

UserSchema.(login: '', age: 17).hints
# {:login=>["length must be within 3 - 64"], :age=>[]}
```

### Support for “OR” messages
It’s probably safe to say dry-validation is the first validation library in Ruby which supports error messages for “OR” rules. Check it out:

``` ruby
PostSchema = Dry::Validation.Form do
  required(:tags).filled { array? | str? }
end

PostSchema.(tags: 123).errors
# {:tags=>["must be an array or must be a string"]}
```
### Support for custom blocks as predicates
You can now define a rule using a block which is executed in the context of your schema. This is useful for complex rules which need external collaborators provided by the schema. These blocks are treated as high-level rules, which means that they will not be executed if the values they depend on are not valid.

``` ruby
UserSchema = Dry::Validation.Form do
  configure do
    option :ids

    def self.messages
      super.merge(
        en: { errors: { valid_id: 'id is not valid' } }
      )
    end
  end

  required(:id).filled(:int?)

  validate(valid_id: :id) do |id|
    ids.include?(id)
  end
end

schema = UserSchema.with(ids: [1, 2, 3])

schema.(id: 4).errors
# {:valid_id=>["id is not valid"]}
```

### Optional extensions
We’ve added an API for loading optional extensions, and we already have one - support for dry-monads. If you add `dry-monads` to your Gemfile, you can load the extension and validation results will become compatible with `Either` monad.

``` ruby
Dry::Validation.load_extensions(:monads)

UserSchema = Dry::Validation.Form do
  required(:login).filled(size?: 3..64)
  required(:age).filled(:int?, gt?: 18)
end

result = UserSchema.(login: '', age: 17).to_either
result.fmap { |data| data[:login] }.or { 'oops' }.value
# "oops"

result = UserSchema.(login: 'jane', age: 19).to_either
result.fmap { |data| data[:login] }.or { 'oops' }.value
# "jane"
```

This means if you happen to use `dry-transaction` or `dry-matcher` you can easily use validation results with them, without the need to wrap results in `Left` or `Right` as it happens automatically.
## dry-types 0.9 and the new dry-struct gem
We’ve extracted `Struct` and `Value` extensions to a separate gem called `dry-struct`, as these APIs started to grow fast and there was demand for more features. Along with the extraction, new features have been added.

### :strict_with_defaults constructor
You can configure structs constructor to be `:strict_with_defaults` which means any unexpected keys in an attributes hash will cause an exception, and missing values will use defaults, assuming you defined them.

``` ruby
require 'dry-struct'

module Types
  include Dry::Types.module
end

class Post < Dry::Struct
  constructor_type(:strict_with_defaults)

  Status = Types::String
    .enum('draft', 'published', 'deleted')
    .default('draft')

  attribute :title, Types::String
  attribute :body, Types::String
  attribute :status, Status
end

Post.new(title: 'hello', body: 'hello, for real', status: nil)
# #<Post title="hello" body="hello, for real" status="draft">

Post.new(title: 'hello', body: 'hello, for real')
# [Post.new] :status is missing in Hash input (Dry::Struct::Error)
```

### :permissive constructor
Previously `:strict` constructor, which is the default one, would silently ignore unexpected keys, now it will raise an error. If you want to rely on the original behavior, simply configure constructor type to `:permissive`:

``` ruby
require 'dry-struct'

module Types
  include Dry::Types.module
end

class Post < Dry::Struct
  constructor_type(:permissive)

  Status = Types::String
    .enum('draft', 'published', 'deleted')
    .default('draft')

  attribute :title, Types::String
  attribute :body, Types::String
  attribute :status, Status
end

Post.new(title: 'hello', body: 'hello, for real', status: published', oops: 'ignored')
# #<Post title="hello" body="hello, for real" status="published">
```

## dry-logic 0.4

Last but not least - the new version of dry-logic is not just few times faster, but also provides a new API for defining and composing Rules. This library is used as the rule engine by dry-validation and dry-types, but you can use it easily standalone too:

``` ruby
age_rule = Dry::Logic.Rule { |v| !v.nil? }.then(
  Dry::Logic.Rule { |v| v.is_a?(Integer) }.and(Dry::Logic.Rule { |v| v > 18 }))

age_rule.(nil).success?
# true
age_rule.(19).success?
# true
age_rule.('19').success?
# false
```

## Thank you <3
Thank you to all contributors who helped finding bugs, testing out new features, providing great feedback and sending pull requests! dry-rb has grown significantly over the last few months and it wouldn’t be possible to achieve that without your help.

Special thanks go to [John Backus](https://github.com/backus) for the dry-struct extraction with new features and improving dry-types at the same time.
