'use strict';
var  path = require('path');
module.exports = function (grunt) {

    var spawn = grunt.util.spawn;

    require('load-grunt-tasks')(grunt);
    require('time-grunt')(grunt);

    function shell() {
        var args = Array.prototype.slice.call(arguments);
        return function(cb) {
            grunt.log.writeln(('Running `' + args.join(' ')+'`').green);
            var child = spawn({
                cmd: args[0],
                args: args.slice(1),
                opts: {
                    cwd: __dirname
                }
            }, cb);
            child.stderr.pipe(process.stderr);
        };
    }

    grunt.registerTask('deploy:staging', '', function(){
        grunt.log.writeln('Deploying to staging');
        var done = this.async();
        grunt.util.async.series([
            shell('git','checkout',  '-b', 'tmp'),
            shell('grunt','build'),
            shell('git','add','-f','dist/'),
            shell('git','commit','-m','"Build"'),
            shell('git','push','-f','staging','tmp:master'),
            shell('git','checkout','master'),
            shell('git','branch','-D','tmp')
        ], done);
    });

    grunt.initConfig({

        mochaTest: {
            test: {
                options: {
                    reporter: 'spec',
                    compilers: 'coffee:coffee-script'
                },
                src: ['test/**/*.coffee']
            }
        },

        express: {
            options: {
                cmd: 'coffee',
                port: process.env.PORT || 9000
            },
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
            dev: {
                files: [{
                    expand: true,
                    cwd: '<%= yeoman.app %>/scripts',
                    src: '{,*/}*.coffee',
                    dest: '<%= yeoman.dev %>/scripts',
                    ext: '.js'
                }]
            },
            dist: {
                files: [{
                    expand: true,
                    cwd: '<%= yeoman.app %>/scripts',
                    src: '{,*/}*.coffee',
                    dest: '<%= yeoman.dist %>/scripts',
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

        yeoman: {
            app: 'app',
            dev: '.tmp',
            dist: 'dist'
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
                        '<%= yeoman.dist %>/*',
                        '!<%= yeoman.dist %>/.git*'
                    ]
                }
                ]
            },
            server: '<%= yeoman.dev %>'
        },

        watch: {
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
                    nospawn: true
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
        'coffee:dev',
        'compass:server',
        'copy:dev',
        'express:dev',
        // 'open',
        'watch'
    ]);

    grunt.registerTask('build', [
        'clean:dist',
        'coffee:dist',
        'compass:dist',
        'copy:dist',
    ]);

    grunt.registerTask('default', 'mochaTest');
};
