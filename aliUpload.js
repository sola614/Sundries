define("js/libs/aliUpload", function (require, exports, module) {
  var base = require('base');
  var aliUpload = {
    // 上传设置，文件，存储路径，成功回调
    uploadFilesToOss: function (data, files, ossPath, renderPicUrl, successCallback, errorCallback) {
      var client = new OSS.Wrapper({
        accessKeyId: data.accessKeyId,
        accessKeySecret: data.accessKeySecret,
        stsToken: data.stsToken,
        bucket: 'allchips-img',
        region: 'oss-cn-shanghai',
        secure: true
      });
      var self = this;
      for (var i = 0, len = files.length; i < len; i++) {
        var file = files[i];
        var myDate = new Date();
        var second = myDate.getTime();
        file.myName = self.randomString() + '.' + file.name.split('.').pop().toLocaleLowerCase(); //file.name.split('.')[0]+'-'+second+'.'+file.name.split('.')[1];
        var ossPicPath = $('.edit-form').data('osspicpath') ? $('.edit-form').data('osspicpath') : renderPicUrl;
        // console.log(ossPath);
        // ossPath = '/test/order/'
        client.multipartUpload(ossPath + file.myName, file).then(function (result) {
          $('.loading-tip').addClass('hide');
          if (result.res.statusCode == 200) {
            result.staticUrl = ossPicPath + ossPath + file.myName;
            result.relativeUrl = ossPath + file.myName;
            result.myName = file.myName;
            result.name = file.name; //.split('-')[0]+'.'+file.myName.split('.')[1];
            successCallback(result);
          } else {
            base.utils.showTip({
              'con': '上传失败,请重试!',
              'hasBtn': true,
              'okText': '关闭'
            }, function () {
              icDialog.close();
              if (errorCallback && typeof errorCallback === "function") {
                errorCallback(result);
              }

            });
          }
        }).catch(function (err) {
          // console.log(err);
          $('.loading-tip').addClass('hide');
          base.utils.showTip({
            'con': '上传失败,请重试!',
            'hasBtn': true,
            'okText': '关闭'
          }, function () {
            icDialog.close();
            if (errorCallback && typeof errorCallback === "function") {
              errorCallback(result);
            }
          });
        });
      }
    },
    // 文件，存储路径，成功回调
    getAliOssKey: function (files, ossPath, renderPicUrl, successCallback, errorCallback) {
      $('.loading-tip').removeClass('hide');
      var cookie = window.document.cookie;
      var v = cookie.match('(^|;) ?accessKeyId=([^;]*)(;|$)');
      //获取授权码
      if (v && (v != 'null' || v != null)) {
        var accessKeyId = v[2];
        var accessKeySecret = cookie.match('(^|;) ?accessKeySecret=([^;]*)(;|$)')[2];
        var stsToken = cookie.match('(^|;) ?securityToken=([^;]*)(;|$)')[2];
        // return {
        //   accessKeyId:accessKeyId,
        //   accessKeySecret:accessKeySecret,
        //   stsToken:stsToken
        // }
        this.uploadFilesToOss({
          accessKeyId: accessKeyId,
          accessKeySecret: accessKeySecret,
          stsToken: stsToken
        }, files, ossPath, renderPicUrl, successCallback, errorCallback);
      } else {
        var that = this;
        base.utils.MyAjax('/product/api/sts', {}, 'post', function (response) {
          var data = response.data;
          var d = new Date();
          d.setTime(d.getTime() + 60 * 60 * 1000);
          window.document.cookie = "accessKeyId=" + data.accessKeyId + ";path=/;domain=.allchips.com;expires=" + d.toGMTString();
          window.document.cookie = "accessKeySecret=" + data.accessKeySecret + ";path=/;domain=.allchips.com;expires=" + d.toGMTString();
          window.document.cookie = "securityToken=" + data.securityToken + ";path=/;domain=.allchips.com;expires=" + d.toGMTString();
          that.uploadFilesToOss({
            accessKeyId: data.accessKeyId,
            accessKeySecret: data.accessKeySecret,
            stsToken: data.securityToken
          }, files, ossPath, renderPicUrl, successCallback);
          // return {
          //   accessKeyId:data.accessKeyId,
          //   accessKeySecret:data.accessKeySecret,
          //   stsToken:data.securityToken
          // }
        })
      }
    },
    randomString: function (len) {
      len = len || 32;
      var $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678'; /****默认去掉了容易混淆的字符oOLl,9gq,Vv,Uu,I1****/
      var maxPos = $chars.length;
      var pwd = '';
      for (i = 0; i < len; i++) {
        pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
      }
      return pwd;
    }
  }
  module.exports = aliUpload;
})
