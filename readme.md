# Komrade

A client library for the komrade worker queue.

## Setup

```bash
$ heroku addons:add komrade:basic
$ gem install komrade-client
```

## Usage

1. Install Gem
2. Enqueue
3. Dequeue

### Install

Gemfile

```ruby
source :rubygems
gem 'komrade-client', '1.0.0'
```

### Enqueue

Example Model

```ruby
class User < ActiveRecord::Base
  after_create :enqueue_welcome_email

  def self.send_welcome_email(id)
    if u = find(id)
      Mailer.welcome(u).deliver
    end
  end

  def enqueue_welcome_email
    Komrade.enqueue("User.send_welcome_email", self.id)
  end
end
```

### Dequeue

Rakefile

```ruby
require 'komrade/tasks'
```

Procfile

```
web: bundle exec rails s
worker: bundle exec rake komrade:work
```
