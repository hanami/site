---
title: dry-rb adopts Zeitwerk for code loading
date: 2022-10-17 12:00 UTC
author: Peter Solnica
---

For the past few months we’ve been working on making all dry-rb gems auto-loadable through [Zeitwerk](https://github.com/fxn/zeitwerk). This is part of a bigger effort as Zeitwerk is also used by [Hanami 2.0](https://github.com/hanami/hanami).

Using Zeitwerk to autoload not just your application code but also your dependencies leads to significantly faster boot times. That’s why it’s worth going through this process to have all the dry-rb gems use Zeitwerk ⚡

### Updated gems

During the last few days we’ve released the following gems that now use Zeitwerk's GemLoader:

- [dry-core 0.9.0](https://github.com/dry-rb/dry-core/releases/tag/v0.9.0)
- [dry-configurable 0.16.0](https://github.com/dry-rb/dry-configurable/releases/tag/v0.16.0)
- [dry-logic 1.3.0](https://github.com/dry-rb/dry-logic/releases/tag/v1.3.0)
- [dry-schema 1.11.2](https://github.com/dry-rb/dry-schema/releases/tag/v1.11.2)
- [dry-validation 1.9.0](https://github.com/dry-rb/dry-validation/releases/tag/v1.9.0)
- [dry-types 1.6.0](https://github.com/dry-rb/dry-types/releases/tag/v1.6.0)
- [dry-struct 1.5.0](https://github.com/dry-rb/dry-struct/releases/tag/v1.5.0)
- [dry-monads 1.5.0](https://github.com/dry-rb/dry-monads/releases/tag/v1.5.0)
- [dry-monitor 0.7.0](https://github.com/dry-rb/dry-monitor/releases/tag/v0.7.0)
- [dry-events 0.4.0](https://github.com/dry-rb/dry-events/releases/tag/v0.4.0)
- [dry-effects 0.3.0](https://github.com/dry-rb/dry-effects/releases/tag/v0.3.0)
- [dry-system 0.27.2](https://github.com/dry-rb/dry-system/releases/tag/v0.27.2)

### How to upgrade

In theory, everything should just work, but we’ve already found there can be various issues depending on how you require files from dry-rb gems. Luckily, the changes that may be required are very simple:

- Change “cherry picking” requires of individual gem files (assuming you have them) to be just a single require of the gem’s entrypoint. Here's a couple of examples:

```ruby
# before
require "dry/core/class_attributes"

# now
require "dry/core"
```

or

```ruby
# before
require "dry/system/container"

# now
require "dry/system"
```

- In case of dry-validation and its own dry-rb dependencies, please make sure that you upgrade everything to the **current** versions.  Unfortunately, dry-validation 1.9.0 may still be installed with dry-schema < 1.11 due to how version requirements work in Rubygems. It’s best to have something like this in your Gemfile:
```ruby
gem "dry-validation", "~> 1.9.0"
gem "dry-schema", "~> 1.11.2"
```

- If you already use Zeitwerk and have teardown code in your test suite, please take a look how we’ve set it up in Hanami’s test suite to clear only the parts we need, without affecting loaders from other gems:

```ruby
def autoloaders_teardown!
  # Tear down Zeitwerk (from zeitwerk's own test/support/loader_test)
  Zeitwerk::Registry.loaders.reject! do |loader|
    test_loader = loader.dirs.any? do |dir|
      dir.include?("/spec/") || dir.include?(Dir.tmpdir) ||
        dir.include?("/slices/") || dir.include?("/app")
    end

    if test_loader
      loader.unregister
      true
    else
      false
    end
  end
end
```

### Reporting issues

If you find any crashes related to Ruby constants, please try to report them in the repository where the given missing constant is actually defined. If you’re unsure, just report them in the repository of the gem that you upgraded and gave you trouble.
