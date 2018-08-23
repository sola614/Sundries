const axios = require('axios');
module.exports = async function (ctx, next) {
  ctx.state.site = {
    title:'',
    keyword:'',
    description:''
  };
  let cookies = ctx.cookies;
  let apiPath = ctx.state.apiPath;
  await ctx.render('index', {
    apiPath,
    baseHomePage: true
  });
  await next();
};
