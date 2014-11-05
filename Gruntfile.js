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
    },
    shell: {
        dirListing: {
            command: 'ls -lrt test/bin'
        }
    }
  });
  grunt.loadNpmTasks('grunt-chmod');
  grunt.loadNpmTasks('grunt-shell');
};
