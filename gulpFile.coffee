"user strict"

gulp 	= require "gulp"
jade 	= require "gulp-jade"
sass 	= require "gulp-sass"
csso	= require "gulp-csso"
jshint 	= require "jshint"

gulp.task "jshint", ->
	gulp.src  "public/lib/jquery/dist/jquery.js"
	.pipe jshint()
	.pipe jshint.reporter "default"

gulp.task "compile-jade", ->
	gulp.src "public/templates/**/*.jade"
	.pipe jade
		pretty: true
	.pipe gulp.dest "public/templates/"

gulp.task "compile-sass", ->
	gulp.src "public/styles/**/*.sass"
	.pipe sass
		includePaths: "public/styles"
		errLogToConsole: true
	.pipe gulp.dest "public/styles/"

gulp.task "compile-coffee", ->
	gulp.src "public/scripts/**/*.coffee"
	.pipe jade
		pretty: true
	.pipe gulp.dest "public/scripts/"