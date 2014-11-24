"user strict"

gulp 				= require "gulp"
gutil				= require "gulp-util"
watch				= require "gulp-watch"
plumber			= require "gulp-plumber"
del					= require "del"
changed			= require "gulp-changed"
concat			= require "gulp-concat"
jade 				= require "gulp-jade"
sass 				= require "gulp-sass"
csso				= require "gulp-csso"
jshint 			= require "gulp-jshint"
coffee			= require "gulp-coffee"
uglify			= require "gulp-uglify"
imagemin		= require "gulp-imagemin"
size				= require "gulp-size"
fs					= require "fs"
mkdirp			= require "mkdirp"
_						= require "lodash"

# Clean Existing Build Files
gulp.task("clean", ->
	del(["public/build"])
)

# Initialize Directories
gulp.task("initialize", ->
	bundleDestinations = ["public/build","public/build/scripts", "public/build/styles", "public/build/images"]
	_.forEach(bundleDestinations, (dest)->
		mkdirp.sync dest
	)

	gulp.src(bundleDestinations)
	.pipe(gutil.noop())
)

# Task for jsHint
gulp.task("run:jshint", ->
	gulp.src("public/scripts/**/*.js")
	.pipe(jshint())
	.pipe(jshint.reporter "default")
)

# Compile JADE Templates
gulp.task("compile:jade", ->
	gulp.src("public/templates/**/*.jade")
	.pipe(
		changed("public/templates/",
			extension: ".html"
		)
	)
	.pipe(jade
		pretty: true
	)
	.pipe(gulp.dest("public/templates/"))
)

# Compile SASS Styles
gulp.task("compile:sass", ->
	gulp.src("public/styles/**/*.sass")
	.pipe(
		changed("public/styles/",
			extension: ".css"
		)
	)
	.pipe(sass(
			includePaths: "public/styles"
			errLogToConsole: true
		)
	)
	.pipe(gulp.dest("public/styles/"))
)

# Compile Coffee Script
gulp.task("compile:coffee", ->
	gulp.src("public/scripts/**/*.coffee")
	.pipe(
		changed("public/scripts/",
			extension: ".js"
		)
	)
	.pipe coffee(
		bare:true
	).on("error", gutil.log)
	.pipe(gulp.dest("public/scripts/"))
)


# Process Asset Bundles
assets = JSON.parse(fs.readFileSync("./assets.json"))
jsBundles = []
cssBundles = []

_.forEach(Object.keys(assets), (assetKey) ->
	asset = assets[assetKey]
	if asset.js
		if (Object.keys(asset.js).length == 1)
			key = Object.keys(asset.js)[0]

			jsBundles.push(
				name: assetKey + "-js"
				file: key.substr(key.lastIndexOf("/") + 1)
				dir: key.substr(0, key.lastIndexOf("/"))
				source: asset.js[key]
			)

	if asset.css
		if (Object.keys(asset.css).length == 1)
			key = Object.keys(asset.css)[0]
			cssBundles.push(
				name: assetKey + "-css"
				file: key.substr(key.lastIndexOf("/") + 1)
				dir: key.substr(0, key.lastIndexOf("/"))
				source: asset.css[key]
			)
)

jsTasks = _.map(jsBundles, (bundle) ->
	gulp.task(bundle.name, ["initialize", "compile:coffee"], ->
		gulp.src bundle.source
		.pipe jshint()
		.pipe concat (bundle.file)
		.pipe uglify()
		.pipe gulp.dest bundle.dir
	)
)

cssTasks = _.map(cssBundles,(bundle) ->
	gulp.task(bundle.name, ["initialize", "compile:sass"], ->
		gulp.src bundle.source
		.pipe concat (bundle.file)
		.pipe csso()
		.pipe gulp.dest bundle.dir
	)
)

gulp.task("bundle:scripts", _.map(jsBundles, (bundle)->
	bundle.name
))

gulp.task("bundle:styles", _.map(cssBundles, (bundle)->
	bundle.name
))

# Watch Coffee Script Changes
gulp.task("watch:coffee", ->
	watch("public/scripts/**/*.coffee")
	.pipe(plumber())
	.pipe(
		changed("public/scripts/",
			extension: ".js"
		)
	)
	.pipe coffee(
		bare:true
	).on("error", gutil.log)
	.pipe(gulp.dest("public/scripts/"))
)

# Watch SASS Styles Changes
gulp.task("watch:sass", ->
	watch("public/styles/**/*.sass")
	.pipe(plumber())
	.pipe(
		changed("public/styles/",
			extension: ".css"
		)
	)
	.pipe(sass(
			includePaths: "public/styles"
			errLogToConsole: true
		)
	)
	.pipe(gulp.dest("public/styles/"))
)

# Watch JADE Template Changes
gulp.task("watch:jade", ->
	watch("public/templates/**/*.jade")
	.pipe(plumber())
	.pipe(
		changed("public/templates/",
			extension: ".html"
		)
	)
	.pipe(jade
			pretty: true
	)
	.pipe(gulp.dest("public/templates/"))
)

gulp.task("optimize:images", ["initialize"], ->
	gulp.src("public/images/**/*")
	.pipe(if process.env.NODE_ENV == "production" then imagemin(
		optimizationLevel: 5
		progressive: true
		interlaced: true
	) else gutil.noop())
	.pipe(gulp.dest("public/build/images"))
	.pipe(size())
)

gulp.task("watch:images", ["initialize"], ->
	watch("public/images/**/*")
	.pipe(gulp.dest("public/build/images"))
)

# Task for development With Watch
gulp.task("dev", ["clean", "compile:jade", "bundle:styles", "bundle:scripts", "optimize:images", "watch:coffee", "watch:sass", "watch:jade", "watch:images"])

# Default Task Without Watch
gulp.task("default", ["clean", "compile:jade", "bundle:styles", "bundle:scripts", "optimize:images"])