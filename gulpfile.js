'use strict';

var del = require('del');
var gulp = require('gulp');
var less = require('gulp-less');
var uncss = require('gulp-uncss');
var combiner = require('stream-combiner2');
var sourcemaps = require('gulp-sourcemaps');
var less_clean = require('less-plugin-clean-css');
var less_prefix = require('less-plugin-autoprefix');

var uncss = uncss({ html: ['index.html', 'docs.html'] });
var clean = new less_clean({ advanced: true });
var prefix = new less_prefix({ browsers: ['last 2 versions'] });

var src = {
  less: 'styles/styles.less'
};

var dist = {
  css: 'css/'
};

gulp.task('clean', function (cb) {
  del([dist.css], cb);
});

/**
 * Compiles Less + sourcemaps
 */

gulp.task('build', function () {
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

gulp.task('watch', ['build'], function () {
  gulp.watch(src.less, ['build']);
});

/**
 * * Compiles Less no sourcemaps
 */

gulp.task('dist', ['clean'], function () {
  return combiner.obj([
    gulp.src(src.less),
    less({ plugins: [clean, prefix] }),
    uncss,
    gulp.dest(dist.css)
    ]).on('error', console.error.bind(console));
});

gulp.task('default', ['watch']);
