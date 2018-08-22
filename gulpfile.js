const gulp = require("gulp");
const uglify = require("gulp-uglify"); //压缩js
// const concat = require('gulp-concat');//合并
const cleanCSS = require("gulp-clean-css"); //压缩css
const pump = require("pump"); //压缩js需要
const clean = require("gulp-clean");
const gulpCopy = require("gulp-copy");
const imagemin = require("gulp-imagemin");

const jsFiles = [
  "./assets/js/**/**/*.js",
  "./assets/seajs/*.js",
  "!./assets/js/libs/datepicker/**"
];
const cssFiles = ["./assets/css/**/*.css"];
const imgFiles = ["./assets/images/**/*.{jpg,png,gif,ico}"];

gulp.task("clean", cb => {
  return gulp.src(["dist/*"]).pipe(clean({ force: true }));
});

gulp.task("copy", cb => {
  return gulp
    .src(
      [
        "assets/js/libs/datepicker/*",
        "assets/js/libs/datepicker/**/**/*",
        "assets/js/libs/plupload/**",
        "assets/fonts/*",
        "assets/video/*",
        "assets/images/**/*",
        "assets/favicon.ico"
      ],
      { base: "." }
    )
    .pipe(gulp.dest("dist"));
});

gulp.task("minifyJs", cb => {
  pump(
    [
      gulp.src(jsFiles, { base: "." }),
      uglify({
        ie8: true,
        mangle: { reserved: ["$", "require", "exports"] },
        compress: {
          drop_console: true
        }
      }),
      gulp.dest("dist")
    ],
    cb
  );
});

gulp.task("minifyCss", () => {
  gulp
    .src(cssFiles)
    .pipe(cleanCSS({ compatibility: "ie8", rebase: false }))
    .pipe(gulp.dest("dist/assets/css"));
});

gulp.task("imagemin", function() {
  gulp
    .src(imgFiles)
    .pipe(imagemin())
    .pipe(gulp.dest("dist/assets/images"));
});

gulp.task("default", ["clean"], () => {
  gulp.start("copy");
  gulp.start("copy", "minifyJs", "minifyCss");
});
