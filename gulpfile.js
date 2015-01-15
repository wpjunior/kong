'use strict'

var del = require('del')
var gulp = require('gulp')
var less = require('gulp-less')
var sourcemaps = require('gulp-sourcemaps')
var less_clean = require('less-plugin-clean-css')
var less_prefix = require('less-plugin-autoprefix')

var clean = new less_clean({ advanced: true })
var prefix = new less_prefix({ browsers: ['last 2 versions'] })

var src = {
  less: 'styles/**/*.less'
}

var dist = {
  css: 'css/'
}

gulp.task('clean', function (cb) {
  del([dist.css], cb)
})

/**
 * Compiles Less + sourcemaps
 */
gulp.task('build', function () {
  return gulp
    .src(src.less)
    .pipe(sourcemaps.init())
    .pipe(less({
      plugins: [clean, prefix]
    }))
    .pipe(sourcemaps.write(dist.css + '/maps'))
    .pipe(gulp.dest(dist.css))
})

/**
 * Watches css changes
 */
gulp.task('watch', ['build'], function () {
  gulp.watch(src.less, ['build'])
})

/**
 * * Compiles Less no sourcemaps
 */
gulp.task('dist', ['clean'], function () {
  return gulp
    .src(src.less)
    .pipe(less({
      plugins: [clean, prefix]
    }))
    .pipe(gulp.dest(dist.css))
})

gulp.task('default', ['watch'])
