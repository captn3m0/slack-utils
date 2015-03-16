require '../loadenv.coffee'
slack = require '../api.coffee'
assert = require 'assert'

api = slack(process.env.API_TOKEN, 'http://httpbin.org/post')

it 'should post message to channel', (done)->
  api.postMessage("Hello", "general", "ghost")
  .on 'error', (err)->
    assert.fail 'TEST', 'TEST', "Request Failed"
    done()
  .on 'data', (res)->
    json = JSON.parse(res.toString()).json
    assert.deepEqual json,
      channel: '#general',
      text:  'Hello',
      username: 'ghost',
      parse: 'full'
    done()

it 'should post a DM', (done)->
  api.sendMessage('Message', 'nemo', 'ghost')
  .on 'data', (res)->
    json = JSON.parse(res.toString()).json
    assert.deepEqual json,
      channel: '@nemo',
      text:  'Message',
      username: 'ghost',
      parse: 'full'
    done()
