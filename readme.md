# Komrade Client

A small, Ruby superset of Komrade's [HTTP API](https://gist.github.com/4641301)

## Setup

Email beta@komrade.io with your heroku email address for a beta pass.

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
gem 'komrade-client', '1.0.11'
```

### Enqueue

Simple Example

```bash
$ export KOMRADE_URL=https://u:p@service.komrade.io
$ ruby -r komrade-client -e 'Komrade::Queue.enqueue("puts", "hello world")'
$ ruby -r komrade-client -e 'puts Komrade::Queue.dequeue'
```

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
    Komrade::Queue.enqueue("User.send_welcome_email", self.id)
  end
end
```

### Dequeue

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

