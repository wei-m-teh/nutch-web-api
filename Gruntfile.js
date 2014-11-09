module.exports = function(grunt) {
  
  grunt.initConfig({
    chmod: {
      options: {
        mode: '755'
      },
      test: {
        src: ['**/nutch']
      }
    },
    clean: {
        coverage: {
          src: ['npm-debug.log', 'reports/']
        }
      },
    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          quiet: false, // Optionally suppress output to standard out (defaults to false)
          clearRequireCache: false, // Optionally clear the require cache before running tests (defaults to false)
          require: ['coffee-script/register', 'coverage/blanket.coffee']
        },
        src: ['test/*.coffee']
      },
      coverage: {
        options: {
          reporter: 'html-cov',
          quiet: true,
          // specify a destination file to capture the mocha
          // output (the quiet option does not suppress this)
          reporter: 'html-cov',
          captureFile: 'reports/coverage.html'
        },
        src: ['test/*.coffee']
      },
      // The travis-cov reporter will fail the tests if the
      // coverage falls below the threshold configured in package.json
      'travis-cov': {
        options: {
          reporter: 'travis-cov'
        },
        src: ['test/*.coffee']
      }
    }
  });

  grunt.loadNpmTasks('grunt-chmod');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('blanket');
  grunt.registerTask('test', ['clean', 'mochaTest']);
};
