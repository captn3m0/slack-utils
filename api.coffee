request = require('request')

listToHash = (list, keyName)->
  list = list[keyName]
  hash = {}
  for item in list
    hash[item.id] = item.name
  hash

data = {}

getUsers = (token)->
  request.get {url: "https://slack.com/api/users.list?token=#{token}", json: true}, (err, res, users)->
    throw err if err
    data['users'] = listToHash users, "members"

getChannels = (token)->
  request.get {url: "https://slack.com/api/channels.list?token=#{token}", json: true}, (err, res, channels)->
    throw err if err
    data['channels'] = listToHash channels, "channels"

module.exports = (API_TOKEN, HOOK_URL)->

  if API_TOKEN?
    getUsers(API_TOKEN)
    getChannels(API_TOKEN)

  postMessage: (message, channel, nick)->
    request.post
      url: HOOK_URL
      json:
        text:     message
        username: nick
        parse:    "full"
        channel: channel

  sendMessage: (message, to, as)->
    request.post
      url: HOOK_URL
      json:
        text:     message
        username: as
        parse:    "full"
        channel: "@#{to}"
  
  # exporting this to test the method
  listToHash: listToHash
  parseMessage: (message)->
    message
      .replace("<!channel>", "@channel")
      .replace("<!group>", "@group")
      .replace("<!everyone>", "@everyone")
      .replace /<#(C\w*)>/g, (match, channelId)->
        "##{data['channels'][channelId]}"
      .replace /<@(U\w*)>/g, (match, userId)->
        "@#{data['users'][userId]}"
      .replace /<(\S*)>/g, (match, link)->
        link