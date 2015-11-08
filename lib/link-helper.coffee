{CompositeDisposable} = require 'atom'
request = require 'request'

module.exports = LinkHelper =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'link-helper:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    if editor = atom.workspace.getActiveTextEditor()
      grammar = editor.getGrammar()
      url = selection = editor.getSelectedText()

      if !url
        return

      if !url.match(/^https?:\/\//)
        url = "http://#{url}"

      request.get({url: url}, (error, response, body) ->
        if error
          return

        title = ''
        if body && matches = body.match(/<title>(.+?)<\/title>/im)
          title = matches.pop()

        if grammar.name.match(/markdown/i)
          editor.insertText("[#{title}](#{url})")
        else
          editor.insertText("<a href=\"#{url}\">#{title}</a>")
      )
