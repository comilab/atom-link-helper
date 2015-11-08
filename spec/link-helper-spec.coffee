LinkHelper = require '../lib/link-helper'
s = require './_server'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "LinkHelper", ->
  workspaceElement = null
  server = null

  title = 'Title'

  beforeEach ->
    server = s.create("<title>#{title}</title>")

    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.packages.activatePackage('language-gfm')

    waitsForPromise ->
      activationPromise = atom.packages.activatePackage('link-helper')
      atom.commands.dispatch workspaceElement, 'link-helper:convert'
      return activationPromise

  afterEach ->
    server.close()

  it 'converts into an <a> tag', ->
    changeHandler = jasmine.createSpy('changeHandler')
    editor = null

    waitsForPromise ->
      atom.workspace.open().then (e) ->
        editor = e

    runs ->
      editor.insertText(server.url)
      editor.selectAll()
      editor.onDidChange(changeHandler)
      atom.commands.dispatch workspaceElement, 'link-helper:convert'

    waitsFor ->
      changeHandler.callCount > 0

    runs ->
      expect(editor.getText()).toEqual "<a href=\"#{server.url}\">#{title}</a>"

  it 'converts into a markdown text', ->
    changeHandler = jasmine.createSpy('changeHandler')
    editor = null

    waitsForPromise ->
      atom.workspace.open('test.md').then (e) ->
        editor = e

    runs ->
      editor.insertText(server.url)
      editor.selectAll()
      editor.onDidChange(changeHandler)
      atom.commands.dispatch workspaceElement, 'link-helper:convert'

    waitsFor ->
      changeHandler.callCount > 0

    runs ->
      expect(editor.getText()).toEqual "[#{title}](#{server.url})"
