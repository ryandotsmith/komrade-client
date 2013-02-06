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
2. Minimalist Example
3. Rails Example
4. Komrade Dashboard

### Install Gem

Gemfile

```ruby
source :rubygems
gem 'komrade-client', '~> 1.0.13'
```

### Minimalist Example ###

This is the absolute bare minimum to see Komrade in action.

```bash
$ export KOMRADE_URL=https://{heroku_username}:{heroku_password}@service.komrade.io
$ ruby -r komrade-client -e 'Komrade::Queue.enqueue("puts", "hello world")'
$ ruby -r komrade-client -e 'puts Komrade::Queue.dequeue'
```

You should see "hello world" output in your terminal.

### Rails Example ###

To get started add  `gem 'komrade-client', '~> 1.0.13'` to your Gemfile. Then run
`rails g komrade`. This will add a komrade-worker process to your Procfile (feel
free to edit your Procfile by hand if you prefer).

Your Procfile now should look something like this:
```
web: bundle exec rails s
komrade-worker: bundle exec rake komrade:work
```

This is an example of a Rails model that sends a welcome email upon user sign up.
The only code that is unique to Komrade here is the `Komrade::Queue.enqueue` method.
This method takes a method as a string and any parameters you want to pass to that method.

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

When you deploy your code, the will queue be ready to accept jobs, and the worker process
is waiting to do the work.


### Komrade Dashboard

```bash
$ heroku addons:open komrade:test
```

![img](http://f.cl.ly/items/0G3f0B2J3J40451h0k3I/Screen%20Shot%202013-01-27%20at%2010.41.53%20PM.png)

