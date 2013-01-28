# Komrade

A client library for the komrade worker queue.

## Setup

Email komrade@32k.io with your heroku email address for a beta pass.

```bash
$ heroku addons:add komrade:test
$ gem install komrade-client
```

## Usage

1. Install Gem
2. Enqueue
3. Dequeue
4. Komrade Dashboard

### Install

Gemfile

```ruby
source :rubygems
gem 'komrade-client', '1.0.1'
```

### Enqueue

Example Model

```ruby
require 'komrade-client/queue'

class User < ActiveRecord::Base
  after_create :enqueue_welcome_email

  def self.send_welcome_email(id)
    if u = find(id)
      Mailer.welcome(u).deliver
    end
  end

  def enqueue_welcome_email
    Komrade::Queue.enqueue("User.send_welcome_email", self.id)
  end
end
```

### Dequeue

Rakefile

```ruby
require 'komrade-client/tasks'
```

Procfile

```
web: bundle exec rails s
worker: bundle exec rake komrade:work
```

### Komrade Dashboard

```bash
$ heroku addons:open komrade:test
```

![img](http://f.cl.ly/items/0G3f0B2J3J40451h0k3I/Screen%20Shot%202013-01-27%20at%2010.41.53%20PM.png)
