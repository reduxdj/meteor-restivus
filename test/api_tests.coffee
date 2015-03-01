if Meteor.isServer
  Meteor.startup ->

    describe 'A Restivus API', ->
      context 'that hasn\'t been configured', ->
        it 'should have default settings', (test) ->
          test.equal Restivus.config.apiPath, 'api/'
          test.isFalse Restivus.config.useAuth
          test.isFalse Restivus.config.prettyJson
          test.equal Restivus.config.auth.token, 'services.resume.loginTokens.token'

        it 'should allow you to add an unconfigured route', (test) ->
          Restivus.addRoute 'test1', {authRequired: true, roleRequired: 'admin'},
            get: ->
              1

          route = Restivus.routes[0]
          test.equal route.path, 'test1'
          test.equal route.endpoints.get(), 1
          test.isTrue route.options.authRequired
          test.equal route.options.roleRequired, 'admin'
          test.isUndefined route.endpoints.get.authRequired
          test.isUndefined route.endpoints.get.roleRequired

        it 'should allow you to add an unconfigured collection route', (test) ->
          Restivus.addCollection new Mongo.Collection('tests'),
            routeOptions:
              authRequired: true
              roleRequired: 'admin'
            endpoints:
              getAll:
                action: ->
                  2

          route = Restivus.routes[1]
          test.equal route.path, 'tests'
          test.equal route.endpoints.get.action(), 2
          test.isTrue route.options.authRequired
          test.equal route.options.roleRequired, 'admin'
          test.isUndefined route.endpoints.get.authRequired
          test.isUndefined route.endpoints.get.roleRequired

        it 'should be configurable', (test) ->
          Restivus.configure
            apiPath: 'api/v1'
            useAuth: true
            prettyJson: true
            auth: token: 'apiKey'

          config = Restivus.config
          test.equal config.apiPath, 'api/v1/'
          test.equal config.useAuth, true
          test.equal config.prettyJson, true
          test.equal config.auth.token, 'apiKey'

      context 'that has been configured', ->
        it 'should not allow reconfiguration', (test) ->
          test.throws Restivus.configure, 'Restivus.configure() can only be called once'

        it 'should configure any previously added routes', (test) ->
          route = Restivus.routes[0]
          test.equal route.endpoints.get.action(), 1
          test.isTrue route.endpoints.get.authRequired
          test.equal route.endpoints.get.roleRequired, ['admin']

        it 'should configure any previously added collection routes', (test) ->
          route = Restivus.routes[1]
          test.equal route.endpoints.get.action(), 2
          test.isTrue route.endpoints.get.authRequired
          test.equal route.endpoints.get.roleRequired, ['admin']



#Tinytest.add 'A route - should be configurable', (test)->
#  Restivus.configure
#    apiPath: '/api/v1'
#    prettyJson: true
#    auth:
#      token: 'apiKey'
#
#  test.equal Restivus.config.apiPath, '/api/v1'
