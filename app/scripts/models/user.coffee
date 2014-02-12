App.users = Em.A()

App.User = Ember.Object.extend()

App.findOrCreate = (collection, model, attr, value) ->
  record = collection.findBy(attr, value)
  unless record?
    params = {}
    params[attr] = value
    record = model.create params
    collection.pushObject(record)
  record

App.findOrCreateUser = (id) ->
  App.findOrCreate(App.users, App.User, 'id', id)
