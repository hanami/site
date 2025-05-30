---
title: Introduction & Usage
pages:
  - container-version
  - params-and-options
  - tolerance-to-unknown-arguments
  - optionals-and-defaults
  - type-constraints
  - readers
  - inheritance
  - skip-undefined
  - attributes
  - rails-support
---

`dry-initializer` is a simple mixin of class methods `params` and `options` for instances.

## Synopsis

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param  :name,  proc(&:to_s)
  param  :role,  default: proc { 'customer' }
  option :admin, default: proc { false }
  option :phone, optional: true
end

user = User.new 'Vladimir', 'admin', admin: true

user.name  # => 'Vladimir'
user.role  # => 'admin'
user.admin # => true
user.phone # => nil
```
