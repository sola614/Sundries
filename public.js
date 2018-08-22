const axios = require('axios');
//并发请求
async function request(urlArr, ctx) {
  let apiPath = ctx.state.apiPath;
  let promises = urlArr.map((item) => {
    return axios.post(apiPath + item.url, item.senData, {
      headers: {
        cookie: ctx.req.headers.cookie || []
      }
    }).then((response) => {
      return response.data;
    })
  });
  let sdata = await Promise.all(promises);
  return sdata;
}
module.exports = {
  request
};
