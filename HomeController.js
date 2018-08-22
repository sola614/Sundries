const axios = require('axios');
module.exports = async function (ctx, next) {
  ctx.state.site = {
    title:'硬之城 - 智能化元器件供应链服务平台',
    keyword:'硬之城,元器件供应链',
    description:'硬之城是基于大数据与人工智能的元器件供应链解决方案服务平台商城，提供元器件在线交易、项目风险控制及BOM管理等可视化供应链服务'
  };
  let cookies = ctx.cookies;
  let apiPath = ctx.state.apiPath;
  await ctx.render('index', {
    apiPath,
    baseHomePage: true
  });
  await next();
};
