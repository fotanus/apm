path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'
wrench = require 'wrench'
apm = require '../lib/apm-cli'

listPackages = (callback) ->
  callback = jasmine.createSpy('callback')
  apm.run(['list'], callback)

  waitsFor -> callback.callCount is 1

  runs(callback)

describe 'apm list', ->
  [resourcePath, atomHome] = []

  beforeEach ->
    silenceOutput()
    spyOnToken()

    resourcePath = temp.mkdirSync('apm-resource-path-')
    fs.writeFileSync(path.join(resourcePath, 'package.json'), JSON.stringify({packageDependencies:{'test-module': '1.0'}}))
    process.env.ATOM_RESOURCE_PATH = resourcePath
    atomHome = temp.mkdirSync('apm-home-dir-')
    process.env.ATOM_HOME = atomHome

  it 'lists the packages included the packageDependencies section of the package.json', ->
    packagesPath = path.join(resourcePath, 'node_modules')
    fs.makeTreeSync(packagesPath)
    wrench.copyDirSyncRecursive(path.join(__dirname, 'fixtures', 'test-module'), path.join(packagesPath, 'test-module'))

    listPackages ->
      expect(console.log).toHaveBeenCalled()
      expect(console.log.argsForCall[1][0]).toContain 'test-module@1.0.0'

  it 'lists the installed packages', ->
    packagesPath = path.join(atomHome, 'packages')
    fs.makeTreeSync(packagesPath)
    wrench.copyDirSyncRecursive(path.join(__dirname, 'fixtures', 'test-module'), path.join(packagesPath, 'test-module'))

    listPackages ->
      expect(console.log).toHaveBeenCalled()
      expect(console.log.argsForCall[4][0]).toContain 'test-module@1.0.0'

  it 'labels disabled packages', ->
    packagesPath = path.join(atomHome, 'packages')
    fs.makeTreeSync(packagesPath)
    wrench.copyDirSyncRecursive(path.join(__dirname, 'fixtures', 'test-module'), path.join(packagesPath, 'test-module'))
    configPath = path.join(atomHome, 'config.cson')
    fs.writeFileSync(configPath, 'core: disabledPackages: ["test-module"]')

    listPackages ->
      expect(console.log).toHaveBeenCalled()
      expect(console.log.argsForCall[4][0]).toContain 'test-module@1.0.0 (disabled)'
