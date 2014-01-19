'use strict';
var  path = require('path');
module.exports = function (grunt) {

    // Load grunt tasks automatically
    require('load-grunt-tasks')(grunt);

    // Time how long tasks take. Can help when optimizing build times
    require('time-grunt')(grunt);

    grunt.loadNpmTasks('grunt-express-server');
    // grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-open');

    // Define the configuration for all the tasks
    grunt.initConfig({

        express: {
            options: {
                cmd: 'coffee',
                port: process.env.PORT || 9000
                // Override defaults here
            },
            // livereload: {
            //     options: {
            //         server: path.resolve('./server'),
            //         livereload: true,
            //         serverreload: true,
            //         bases: [path.resolve('./<%= yeoman.dev %>'), path.resolve(__dirname, '<%= yeoman.app %>')]
            //     }
            // },
            dev: {
                options: {
                    script: 'server/app.coffee'
                }
            },
            prod: {
                options: {
                    script: 'server/app.coffee'
                }
            }
        },

        coffee: {
            dist: {
                files: [{
                    expand: true,
                    cwd: '<%= yeoman.app %>/scripts',
                    src: '{,*/}*.coffee',
                    dest: '<%= yeoman.dev %>/scripts',
                    ext: '.js'
                }]
            },
            test: {
                files: [{
                    expand: true,
                    cwd: 'test/spec',
                    src: '{,*/}*.coffee',
                    dest: '<%= yeoman.dev %>/spec',
                    ext: '.js'
                }]
            }
        },

        compass: {
            dist: {
                options: {
                    cssDir: '<%= yeoman.dist %>/styles',
                    importPath: '<%= yeoman.dist %>/bower_components',
                    javascriptsDir: '<%= yeoman.dist %>/scripts',
                    httpImagesPath: '<%= yeoman.dist %>/images',
                    environment: 'production'
                }
            },
            options: {
                sassDir: '<%= yeoman.app %>/styles',
                cssDir: '<%= yeoman.dev %>/styles',
                importPath: '<%= yeoman.app %>/bower_components',
                javascriptsDir: '<%= yeoman.app %>/scripts',
                httpImagesPath: '<%= yeoman.app %>/images'
            },
            server: {
                options: {
                    debugInfo: true
                }
            }
        },

        // connect: {
        //     options: {
        //         port: 9000,
        //         hostname: 'localhost'
        //     },
        //     dev: {
        //         options: {
        //             middleware: function (connect) {
        //                 return [
        //                     require('connect-livereload')()
        //                 ];
        //             }
        //         }
        //     }
        // },

        // Project settings
        yeoman: {
            // Configurable paths
            app: 'app',
            dev: '.tmp',
            dist: 'dist'
        },

        // Watches files for changes and runs tasks based on the changed files
        // watch: {
        //     express: {
        //         files:  [ './app/**/*' ],
        //         tasks:  [ 'express:dev' ],
        //         options: {
        //             livereload: true,
        //             spawn: false // Without this option specified express won't be reloaded
        //         }
        //     }
        // },

        open: {
            server: {
                url: 'http://localhost:<%= express.options.port %>'
            }
        },

        clean: {
            dist: {
                files: [
                    {
                    dot: true,
                    src: [
                        '<%= yeoman.dev %>',
                        '<%= yeoman.dist %>/*',
                        '!<%= yeoman.dist %>/.git*'
                    ]
                }
                ]
            },
            server: '<%= yeoman.dev %>'
        },

        watch: {
            // coffee: {
            //     files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee'],
            //     tasks: ['coffee:dist']
            // },
            // coffeeTest: {
            //     files: ['test/spec/{,*/}*.coffee'],
            //     tasks: ['coffee:test']
            // },
            // compass: {
            //     files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
            //     tasks: ['compass']
            // },
            express: {
                files: [
                    '<%= yeoman.app %>/{,*//*}*.html',
                    '{<%= yeoman.dev %>,<%= yeoman.app %>}/styles/{,*//*}*.css',
                    '{<%= yeoman.dev %>,<%= yeoman.app %>}/scripts/{,*//*}*.js',
                    '<%= yeoman.app %>/images/{,*//*}*.{png,jpg,jpeg,gif,webp,svg}',
                    'server.js',
                    'server/{,*//*}*.{js,json}'
                ],
                tasks: ['express:dev'],
                options: {
                    livereload: true,
                    nospawn: true //Without this option specified express won't be reloaded
                }
            }
        },

        copy: {
            dev: {
                files: [
                    {
                    expand: true,
                    dot: true,
                    cwd: '<%= yeoman.app %>',
                    dest: '<%= yeoman.dev %>',
                    src: [
                        '*.{ico,txt}',
                        '.htaccess',
                        'bower_components/**/*',
                        'images/{,*/}*.*',
                        'styles/fonts/*'
                    ]
                }
                ]
            },
            dist: {
                files: [
                    {
                    expand: true,
                    dot: true,
                    cwd: '<%= yeoman.app %>',
                    dest: '<%= yeoman.dist %>',
                    src: [
                        '*.{ico,txt}',
                        '.htaccess',
                        'bower_components/**/*',
                        'images/{,*/}*.*',
                        'styles/fonts/*'
                    ]
                }
                ]
            }
        }


    });

    grunt.registerTask('server', [
        'clean:server',
        'coffee:dist',
        'compass:server',
        'copy:dev',
        // 'coffee:dist',
        // 'compass:server',
        // 'express:livereload',
        'express:dev',
        'open',
        'watch'
    ]);

    grunt.registerTask('build', [
        'clean:dist',
        // 'jshint',
        // 'test',
        // 'coffee',
        // 'compass:dist',
        // 'useminPrepare',
        // 'imagemin',
        // 'cssmin',
        // 'htmlmin',
        // 'concat',
        'copy:dist',
        // 'cdnify',
        // 'ngmin',
        // 'uglify',
        // 'rev',
        // 'usemin'
    ]);
    // grunt.registerTask('server', [ 'express:dev' ]);
    grunt.registerTask('default', [
        'server'
    ]);
};
