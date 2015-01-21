'use strict';

var del = require('del');
var gulp = require('gulp');
var less = require('gulp-less');
var jade = require('gulp-jade');
var uncss = require('gulp-uncss');
var glob = require('glob');
var combiner = require('stream-combiner2');
var minifycss = require('gulp-minify-css');
var sourcemaps = require('gulp-sourcemaps');
var less_clean = require('less-plugin-clean-css');
var less_prefix = require('less-plugin-autoprefix');

var src = {
  less: 'styles/styles.less',
  views: ['./views/**/*.jade', '!./views/*layout.jade']
};

var dist = {
  css: 'css/',
  views: './'
};

var clean = new less_clean({ advanced: true });
var prefix = new less_prefix({ browsers: ['last 2 versions'] });

uncss = uncss({
  html: glob.sync(dist.views + '*.html')
});

gulp.task('clean', function (cb) {
  del([dist.css, dist.views + '*.html'], cb);
});

/**
 * Compiles Jade
 */
gulp.task('jade', function () {
  return gulp.src(src.views)
      .pipe(jade({
        locals: {
          menuItems: require('./views/menu-items')
        }
      }))
      .pipe(gulp.dest(dist.views));
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
gulp.task('watch', ['jade', 'less'], function () {
  gulp.watch('styles/*.*', ['less']);
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
