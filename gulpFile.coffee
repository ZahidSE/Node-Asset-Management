"user strict"

gulp 		= require "gulp"
gutil		= require "gulp-util"
jade 		= require "gulp-jade"
sass 		= require "gulp-sass"
csso		= require "gulp-csso"
jshint 	= require "gulp-jshint"
coffee	= require "gulp-coffee"

gulp.task "jshint", ->
	gulp.src  "public/scripts/**/*.js"
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
	.pipe coffee(
		bare:true
	).on "error", gutil.log
	.pipe gulp.dest "public/scripts/"