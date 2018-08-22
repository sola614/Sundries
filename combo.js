const fs = require('fs');
const path = require('path');

function queryUrl (name, url) {
  var results,
    params, qrs2, i, len;

  if (typeof (url) !== 'string') {
    return '';
  }

  if (url[0] === '?') {
    url = url.substr(1);
  }

  if (name) {
    results = url.match(new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i'));
    results = results === null ? '' : decodeURIComponent(results[2]);
  } else {
    results = {};
    if (url) {
      params = url.split('&');
      i = 0;
      len = params.length;
      for (i = 0; i < len; i++) {
        qrs2 = params[i].split('=');
        results[qrs2[0]] = (qrs2[1] === void 0 ? '' : decodeURIComponent(qrs2[1]));
      }
    }
  }
  return results;
}


/**
 * 处理url
 * @param  {string} str    请求的全路径
 * @param  {object} config 配置文件
 * @return {object}
 */
function parseUrl (str, config) {
  var data = {},
    index, Prefix;
  //为了查找时间缀
  str = str.replace('??', '@@');
  index = str.lastIndexOf('?');
  if (index > -1) {
    data.type = queryUrl('type', str.slice(index));
    str = str.substr(0, index);
  }
  if (str.indexOf('.css') >= 0) {
    data.type = 'css';
  }
  //默认类型
  if (data.type !== 'js' && data.type !== 'css') {
    data.type = 'js';
  }
  //计算位置
  index = str.indexOf('@@');
  //得到路径前缀
  Prefix = str.substr(0, index) || '';
  //如果不是以/结尾,但这里要判断如果为空
  if (Prefix && Prefix.slice(-1) !== '/') {
    Prefix += '/';
  }
  if (Prefix[0] === '/') {
    Prefix = Prefix.substr(1);
  }
  //路径前缀
  data.prefix = Prefix;
  //文件url数组
  data.files = [];
  str.substr(index + 2).split(',').forEach(function (val) {
    var ext, uri;
    if (!val) {
      return;
    }
    //取扩展名
    ext = path.extname(val);
    //如果没有后缀则使用默认
    if (!ext) {
      ext = data.type;
      val += '.' + ext;
    } else {
      ext = ext.slice(1);
      //如果非法
      if (['js', 'css', 'tpl'].indexOf(ext) === -1) {
        return;
      }
    }
    //生成cmd使用uri
    uri = val[0] === '/' ? val.substr(1) : val;
    //只对js替换
    if (ext === 'js') {
      uri = uri.replace('.js', '');
    }
    //拼数据
    data.files[data.files.length] = {
      path: path.resolve(config.base, val[0] === '/' ? val.substr(1) : Prefix + val), //全路径
      uri: uri,
      ext: ext, //扩展名
      parse: data.type === ext && ext === 'js' ? 'js' : data.type === 'js' && ext === 'css' ? 'css_js' : data.type === 'js' && ext === 'tpl' ? 'tpl_js' : data.type === ext && ext === 'css' ? 'css' : 'js',
    }
  });
  return data;
}

const MIME = {
  "css": "text/css",
  "gif": "image/gif",
  "html": "text/html",
  "ico": "image/x-icon",
  "jpeg": "image/jpeg",
  "jpg": "image/jpeg",
  "js": "application/javascript",
  "json": "application/json",
  "pdf": "application/pdf",
  "png": "image/png",
  "svg": "image/svg+xml",
  "swf": "application/x-shockwave-flash",
  "tiff": "image/tiff",
  "txt": "text/plain",
  "wav": "audio/x-wav",
  "wma": "audio/x-ms-wma",
  "wmv": "video/x-ms-wmv",
  "xml": "text/xml",
  "text": "text/plain"
};

module.exports = function combo (opts) {
  return async function (ctx, next) {
    let result = '';
    let url = ctx.url;
    if (url.indexOf('??') !== -1) {
      let url_data = parseUrl(url, opts);
      url_data.files.forEach(function (value) {
        if (fs.existsSync(value.path)) {
          result += fs.readFileSync(value.path).toString();
        }
      });
      ctx.type = MIME[url_data.type];
      ctx.body = result;
    } else {
      await next();
    }
  }
}
