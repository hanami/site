---
title: Introduction
pages:
  - basic-usage
  - how-does-it-work
  - injection-strategies
---

dry-auto_inject provides low-impact dependency injection and resolution support for your classes.

It’s designed to work with a container that holds your application’s dependencies. It works well with [dry-container](//doc/dry-container), but supports any container that responds to the `#[]` interface.

### Why use dry-auto_inject?

Splitting your application’s behavior into smaller, more focused units makes for logic that is easier to understand, test, and refactor. Dependency injection is what then allows you to combine these small units to create more sophisticated behavior.

By using a container and dry-auto_inject, this process becomes easy. You don’t need to worry about building constructors or accessors, and adding extra dependencies is as easy as adding a string to a list.

### Usage example

```ruby
# Set up a container (using dry-container here)
class MyContainer
  extend Dry::Container::Mixin

  register "users_repository" do
    UsersRepository.new
  end

  register "operations.create_user" do
    CreateUser.new
  end
end

# Set up your auto-injection mixin
Import = Dry::AutoInject(MyContainer)

class CreateUser
  include Import["users_repository"]

  def call(user_attrs)
    users_repository.create(user_attrs)
  end
end

create_user = MyContainer["operations.create_user"]
create_user.call(name: "Jane")
```
