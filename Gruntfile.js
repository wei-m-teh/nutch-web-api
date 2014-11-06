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
  });
  grunt.loadNpmTasks('grunt-chmod');
};
