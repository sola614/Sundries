//文档地址：https://help.aliyun.com/document_detail/66317.html?spm=a2c4g.11186623.4.1.Jspi8I
// 使用：
// 先通过后台接口获取appkey和scene
// var alinc = require('alinc');
// alinc.getAppkey({
//   sceneKey,//这个是自己添加得参数，必填，通过类型获取appkey和scene {10-注册 20-登录 30-找回密码}
//    callback:
// })
// 然后调用init 返回值nc为可操作对象
// var nc = alinc.init({
//   dom,//必填
//   appkey,//必填，但这个不用手动配置
//   scene,//必填，但这个不用手动配置
//   sceneKey,//这个是自己添加得参数，必填，通过类型获取appkey和scene {10-注册 20-登录 30-找回密码}
//   token,//必填，不用手动配置
//   customWidth,
//   trans,
//   elementID,
//   is_Opt,
//   language,
//   isEnabled,
//   timeout,
//   times,
//   apimap,
//   callback:function(data){}
// })

define('js/libs/aliNc', function (require, exports, module) {
  var self, nc, timer;
  var base = require('base');
  var aliNc = {
    init: function (option) {
      self = this;
      var nc_dom = option.dom || '#myNcContainer';//声明滑动验证需要渲染的目标元素ID
      var nc_appkey = option.appkey || 'FFFF0N00000000006699';//应用标示
      var nc_scene = option.scene || '';//场景标示
      var nc_token = [nc_appkey, (new Date()).getTime(), Math.random()].join(':');//滑动验证码的主键，请务必不需要写死固定值。请确保每个用户每次打开页面时，token都是不同的。建议格式为”您的appkey”+”时间戳”+”随机数”
      var nc_customWidth = option.customWidth || 300;//滑动条的长度，建议预留300像素以上
      var nc_trans = option.trans || {};//业务键字段。您可以不写此字段，也可以按照下文中”问题排查与错误码”部分文档配置此字段，便于线上问题排查
      var nc_elementID = option.elementID || [];//通过Dom的ID属性自动填写trans业务键，您可以不写此字段，也可以按照下文中”问题排查与错误码”部分文档配置此字段，便于线上问题排查
      var nc_is_Opt = option.is_Opt || 0;//是否自己配置底层采集组件。如无特殊场景请保持写0或不写此项。默认为0
      var nc_language = option.language || 'cn';//语言。PC场景默认支持18国语言，详细配置方法请见下方”自定义文案与多语言”部分。默认为cn(中文)
      var nc_isEnabled = option.isEnabled || true;//是否启用，无特殊场景请默认写true。默认为true
      var nc_timeout = option.timeout || 3000;//内部网络请求的超时时间，一般不需要改，默认值为3000ms
      var nc_times = option.times || 5;//允许服务器超时重复次数，默认5次
      var nc_apimap = option.apimap || {};//用于自己指定滑动验证各项请求的接口地址。如无特殊情况，请不要配置这里的apimap，配置参考文档

      var NC_Opt =
      {
        renderTo: nc_dom,
        appkey: nc_appkey,
        scene: nc_scene,
        token: nc_token,
        customWidth: nc_customWidth,
        trans: nc_trans,
        elementID: nc_elementID,
        is_Opt: nc_is_Opt,
        language: nc_language,
        isEnabled: nc_isEnabled,
        timeout: nc_timeout,
        times: nc_times,
        apimap: nc_apimap,
        callback: function (data) {
          //返回值有csessionid,sig,token,value
          $('.nc-error')[0] && $('.nc-error').text('').removeClass('item-error-bg');
          data.sceneKey = option.sceneKey;
          data.ncDom = nc;
          typeof option.callback == 'function' && option.callback(data);
        }
      };
      if (window.noCaptcha) {
        nc = new noCaptcha(NC_Opt);
      } else {
        timer = setInterval(function () {
          clearInterval(timer);
          self.init(option);
        }, 200);
        // return false;
      }
      this.upLang(option);
      return nc;
    },
    getAppkey: function (option) {
      if (!$('#alincpc')[0]) {
        loadJsFile && loadJsFile('//g.alicdn.com/sd/ncpc/nc.js?t=' + new Date().getTime(), 'alincpc');
      }
      self = this;
      base.utils.MyAjax('/ucenter/api/users/getCaptchaParams', { "sceneKey": option.sceneKey }, 'post', function (res) {
        if (res.code == 0) {
          // appkey = res.data ? res.data.appkey : '';
          // scene == res.data ? res.data.scene : '';
          // console.log(self.init(option));
          typeof option.callback == 'function' && option.callback(res.data);
        } else {
          base.utils.showTip({
            con: res.message,
            autoClose: true
          });
        }
      });
    },
    reload: function () {
      nc && nc.reload();
    },
    hide: function () {
      nc && nc.hide();
    },
    show: function () {
      nc && nc.show();
    },
    getToken: function () {
      nc && nc.getToken();
    },
    destroy: function () {
      nc && nc.destroy();
    },
    setTrans: function (opt) {
      nc && nc.setTrans(opt);
    },
    getNcDom: function () {
      return nc;
    },
    upLang: function (opt) {
      //自定义文案
      //通过滑动验证对象维护的upLang方法来自定义您需要的文案。内置的语言有简体中文、繁体中文、英文（cn、tw、en）三种，可以选择其中一种进行更新，也可传入一个新名字以建立新语言。如果您调用upLang方法后，自定义文案没有生效，请在其之后调用reload()方法，让滑动验证重新渲染即可
      var lang = opt.lang ? opt.lang : 'cn';
      var startText = opt.startText ? opt.startText : '请按住滑块，拖动到最右边';
      var yesText = opt.yesText ? opt.yesText : '验证通过';
      var error300 = opt.error300 ? opt.error300 : '哎呀，出错了，点击<a href=\"javascript:__nc.reset()\">刷新</a>再来一次';
      var errorNetwork = opt.errorNetwork ? opt.errorNetwork : '网络不给力，请<a href=\"javascript:__nc.reset()\">点击刷新</a>';
      nc && nc.upLang(lang, {
        _startTEXT: startText,
        _yesTEXT: yesText,
        _error300: error300,
        _errorNetwork: errorNetwork,
      });
    }
  };
  module.exports = aliNc;
});
