---
title: Announcing dry-rb
date: 2016-03-16 12:00 UTC
author: Peter Solnica
---

We are thrilled to announce the official launch of [dry-rb](https://github.com/dry-rb) and this brand new website! The dry-rb organization was established on GitHub last year by Andy Holland. He created a couple of small and very useful gems, namely `dry-container` and `dry-configurable`. The organization has since grown very quickly, with more people joining the effort, and today we already have 9 gems released on RubyGems.org and more in the works.

dry-rb is here to help usher in a new phase of Ruby development. We value good encapsulation, reusability and non-intrusiveness. Our gems are small and focused on solving specific problems. They work with each other very well, and can also be used in existing projects.

## New gem releases

Apart from the release of this website, we'd like to announce big releases of [dry-validation](/gems/dry-validation) and [dry-types](/gems/dry-types). Both gems went through major refactorings and come with many great new features, bug fixes and internal improvements.

### dry-validation 0.7.0

This release comes with a redesigned predicate logic engine, provided by dry-logic, and has lots of new features which make defining validation schemas very simple. The DSL is more concise and expressive: you can use convenient macros to reduce the boilerplate, use nested schemas which allow re-using existing schemas, and define high-level rules which depend on one or more values. We also have new interfaces for configuring external dependencies that a schema might need to apply its predicates.

Error messages have been improved too. You can now ask for full messages, which will include rule names, and you can provide translations for these rule names (works both with yaml and i18n translation backends).

The error messages hash is now simpler and works very well with nested structures, including arrays with error messages for individual elements.

`dry-validation` remains very fast. Benchmarks show it's ~2.5x faster than `ActiveModel::Validations`. We'll keep making it faster!

For a complete list of changes please refer to the [CHANGELOG](https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md#v070-2016-03-16).

Here's an example validation schema using new syntax:

``` ruby
require 'dry-validation'

UserSchema = Dry::Validation.Schema do
  key(:email).required

  key(:age).required

  key(:address).schema do
    key(:city).required(min_size?: 3)

    key(:street).required

    key(:country).schema do
      key(:name).required
      key(:code).required
    end
  end
end

UserSchema.(
  email: 'jane@doe.org',
  age: 21,
  address: {
    city: 'NY',
    street: 'Street 1',
    country: { name: '', code: 'US' }
  }
).messages
# {:address=>{:city=>["size cannot be less than 3"], :country=>{:name=>["must be filled"]}}}
```

### dry-types 0.6.0

We renamed the former `dry-data` gem to `dry-types` and have released version 0.6.0. It went through internal refactoring to make composing types more flexible and simpler. This release also comes with nice new features, like support for default values in hash schemas and ability to pass a block to default values. These features make working with Struct and Value types simpler, as you can configure default values for attributes easily now.

For a complete list of changes please refer to the [CHANGELOG](https://github.com/dry-rb/dry-types/blob/main/CHANGELOG.md#v070-2016-03-16).

Here's an example Struct definition which uses these new features:

``` ruby
require 'dry-types'

module Types
  include Dry::Types.module
end

class Post < Dry::Types::Struct
  constructor_type(:schema)

  Status = Types::Strict::String
    .enum('draft', 'published', 'deleted')
    .default('draft')

  CreatedAt = Types::Strict::Time.default { Time.now }

  attribute :status, Status
  attribute :title, Types::Strict::String
  attribute :body, Types::Strict::String
  attribute :created_at, CreatedAt
end

Post.new(title: 'Hello World', body: 'some text')
# => #<Post:0x007fd042838320 @status="draft", @title="Hello World", @body="some text", @created_at=2016-03-16 11:28:41 +0100>
```

## Future plans

We'll continue growing dry-rb, improving the existing gems and adding new ones. Please try out our already released [gems](/gems) and let us know what you think.

If you have any issues, do not hesitate to [talk to us](https://dry-rb.zulipchat.com) or report an issue on GitHub.
