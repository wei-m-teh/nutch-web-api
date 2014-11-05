module.exports = function(grunt) {
  grunt.initConfig({
    chmod: {
      options: {
        mode: '755'
      },
      test: {
       // Target-specific file/dir lists and/or options go here.
        src: ['**/nutch']
      }
    }
  });
  grunt.loadNpmTasks('grunt-chmod');
};
