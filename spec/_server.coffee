http = require 'http'

exports.port = 5555

exports.create = (body = '', port = exports.port) ->
  server = http.createServer (req, res) ->
    if (req.url.match('empty'))
      return res.end()
    res.end(body)
  server.listen(port)
  server.port = port
  server.url = "http://localhost:#{port}"

  return server
