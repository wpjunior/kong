'use strict';

var del = require('del');
var gulp = require('gulp');
var less = require('gulp-less');
var jade = require('gulp-jade');
var uncss = require('gulp-uncss');
var combiner = require('stream-combiner2');
var minifycss = require('gulp-minify-css');
var sourcemaps = require('gulp-sourcemaps');
var less_clean = require('less-plugin-clean-css');
var less_prefix = require('less-plugin-autoprefix');

var uncss = uncss({ html: ['index.html', 'docs.html'] });
var clean = new less_clean({ advanced: true });
var prefix = new less_prefix({ browsers: ['last 2 versions'] });

var src = {
  less: 'styles/styles.less',
  views: ['./views/**/*.jade', '!./views/layout.jade']
};

var dist = {
  css: 'css/',
  views: './'
};

gulp.task('clean', function (cb) {
  del([dist.css], cb);
});

/**
 * Compiles Jade
 */
gulp.task('jade', function () {
  return gulp.src(src.views)
      .pipe(jade())
      .pipe(gulp.dest(dist.views))
});

/**
 * Compiles Less + sourcemaps
 */
gulp.task('less', function () {
  return combiner.obj([
    gulp.src(src.less),
    sourcemaps.init(),
    less({ plugins: [clean, prefix] }),
    uncss,
    sourcemaps.write('maps'),
    gulp.dest(dist.css)
  ]).on('error', console.error.bind(console));
});

/**
 * Watches css changes
 */
gulp.task('watch', ['less'], function () {
  gulp.watch(src.less, ['less']);
  gulp.watch(src.views, ['jade']);
});

/**
 * Compiles Less no sourcemaps
 */
gulp.task('dist', ['clean', 'jade'], function () {
  return combiner.obj([
    gulp.src(src.less),
    less({ plugins: [clean, prefix] }),
    uncss,
    minifycss(),
    gulp.dest(dist.css)
  ]).on('error', console.error.bind(console));
});

gulp.task('default', ['watch']);
