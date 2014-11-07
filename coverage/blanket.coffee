path = require 'path'
srcDir = path.join __dirname, '..'
blanket = require 'blanket'
options = {}
options.pattern = srcDir
blanket(options)