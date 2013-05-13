path = require 'path'
fs = require 'fs'
CSON = require 'season'
config = require './config'

module.exports =
class Lister
  userPackagesDirectory: null
  bundledPackagesDirectory: null

  constructor: ->
    @userPackagesDirectory = path.join(config.getAtomDirectory(), 'packages')
    @bundledPackagesDirectory = path.join(config.getResourcePath(), 'src', 'packages')

  isDirectory: (directoryPath) ->
    try
      fs.statSync(directoryPath).isDirectory()
    catch e
      false

  isFile: (filePath) ->
    try
      fs.statSync(filePath).isFile()
    catch e
      false

  list: (directoryPath) ->
    if @isDirectory(directoryPath)
      try
        fs.readdirSync(directoryPath)
      catch e
        []
    else
      []

  logPackages: (packages) ->
    for pack, index in packages
      if index is packages.length - 1
        prefix = '\u2514\u2500\u2500 '
      else
        prefix = '\u251C\u2500\u2500 '
      console.log "#{prefix}#{pack.name}@#{pack.version}"

  listPackages: (directoryPath) ->
    packages = []
    for child in @list(directoryPath)
      manifestPath = CSON.resolveObjectPath(path.join(directoryPath, child, 'package'))
      try
        manifest = CSON.readObjectSync(manifestPath)
      catch e
        continue

      name = manifest.name ? child
      version = manifest.version ? '0.0.0'
      packages.push({name, version})

    packages

  listUserPackages: ->
    console.log @userPackagesDirectory
    @logPackages(@listPackages(@userPackagesDirectory))


  listBundledPackages: ->
    console.log 'Built-in packages'
    @logPackages(@listPackages(@bundledPackagesDirectory))

  run: (options) ->
    @listUserPackages()
    console.log ''
    @listBundledPackages()
