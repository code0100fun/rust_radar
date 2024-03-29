'use strict';
var  path = require('path');
module.exports = function (grunt) {

    var spawn = grunt.util.spawn;

    require('load-grunt-tasks')(grunt);
    require('time-grunt')(grunt);

    grunt.initConfig({

        browserify: {
            dev: {
                files: {
                    '<%= yeoman.dev %>/scripts/bundle.js' : [
                        'app/scripts/**/*.coffee'
                    ]
                },
                options: {
                    alias: [
                        '<%= yeoman.dev %>/scripts/template.js:templates',
                        'app/scripts/vendor/raphael.pan-zoom.js:raphael.pan-zoom',
                    ],
                    shim: {
                        ember: {
                            path: './app/bower_components/ember/ember.js',
                            exports:'Ember'
                        },
                        jquery: {
                            path: './app/bower_components/jquery/jquery.js',
                            exports:'jQuery'
                        },
                        raphael: {
                            path: './app/bower_components/raphael/raphael.js',
                            exports:'Raphael'
                        },
                        bootstrap: {
                            path: './app/bower_components/bootstrap/dist/js/bootstrap.js',
                            exports: null
                        },
                        equalHeights: {
                            path: './app/bower_components/jquery.equalheights/jquery.equalheights.js',
                            exports: null
                        }
                    },
                    transform: ['coffeeify'],
                    noParse: [
                        'raphael'
                    ]
                }
            }
        },

        uglify: {
            dev: {
                files: {
                    '<%= yeoman.dev %>/scripts/bundle.js': ['<%= yeoman.dev %>/scripts/bundle.js']
                }
            },
            dist: {
                files: {
                    '<%= yeoman.app %>/scripts/bundle.js': ['<%= yeoman.app %>/scripts/bundle.js']
                }
            }
        },

        mochaTest: {
            test: {
                options: {
                    reporter: 'spec',
                    compilers: 'coffee:coffee-script'
                },
                src: ['test/**/*.coffee']
            }
        },

        emblem: {
            compile: {
                files: {
                    '<%= yeoman.dev %>/scripts/template.js': ['app/scripts/templates/**/*.emblem']
                },
                options: {
                    root: 'app/scripts/templates/',
                    dependencies: {
                        jquery: 'app/bower_components/jquery/jquery.js',
                        ember: 'app/bower_components/ember/ember.js',
                        emblem: 'app/bower_components/emblem/dist/emblem.js',
                        handlebars: 'app/bower_components/handlebars/handlebars.js'
                    }
                }
            }
        },

        express: {
            options: {
                cmd: 'coffee',
                port: process.env.PORT || 9000
            },
            server: {
                options: {
                    script: 'server/app.coffee'
                }
            },
        },

        sass: {
            dist: {
                files: {
                    '<%= yeoman.dev %>/styles/main.css':'<%= yeoman.app %>/styles/main.scss'
                }
            }
        },

        concat: {
            css: {
                src: [
                    '<%= yeoman.app %>/bower_components/bootstrap/dist/css/bootstrap.css',
                    '<%= yeoman.dev %>/styles/main.css',
                ],
                dest: '<%= yeoman.dev %>/styles/main.css'
            }
        },

        yeoman: {
            app: 'app',
            dev: '.tmp',
        },

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
                    ]
                }
                ]
            },
            server: '<%= yeoman.dev %>'
        },

        watch: {
            // express: {
            //     files: [
            //         '<%= yeoman.app %>/{,*//*}*.html',
            //         '{<%= yeoman.dev %>,<%= yeoman.app %>}/styles/{,*//*}*.css',
            //         '{<%= yeoman.dev %>,<%= yeoman.app %>}/scripts/{,*//*}*.js',
            //         '<%= yeoman.app %>/images/{,*//*}*.{png,jpg,jpeg,gif,webp,svg}',
            //         'server.js',
            //         'server/{,*//*}*.{js,json}'
            //     ],
            //     tasks: ['express:dev'],
            //     options: {
            //         livereload: true,
            //         nospawn: true
            //     }
            // }
        },

    });

    grunt.registerTask('build', [
        'clean:server',
        'emblem',
        'sass',
        'concat:css',
        'browserify:dev',
    ]);

    grunt.registerTask('server', [
        'build',
        'express:server',
        // 'open',
        'watch'
    ]);


    grunt.registerTask('heroku', [
        'build',
        'uglify:dev',
    ]);

    grunt.registerTask('default', 'mochaTest');
};
