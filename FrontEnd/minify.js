const minify = require('html-minifier').minify;

module.exports = async function (ctx, next) {
  if (ctx.path !== '/') {
    return await next();
  }
  const body = ctx.response.body;
  const minifyedBody = minify(body, {
    minifyCSS: true,
    minifyJS: true,
    collapseWhitespace: true,
    removeTagWhitespace: false,
    useShortDoctype: true,
    removeComments: true,
    processConditionalComments: true,
    decodeEntities: true,
    removeScriptTypeAttributes: true,
    trimCustomFragments: true
  });
  ctx.body = minifyedBody.replace(/,userInfo=\{(.*)\}<\/script>/, '</script>');
  await next();
}
