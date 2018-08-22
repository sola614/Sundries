define("js/libs/aliUploadByIE", function (require, exports, module) {
  var base = require("base");
  require("upload");
  var aliUploadByIE = {
    // 上传设置，文件，存储路径，成功回调
    // website/api/upload/signature
    uploadInit: function (options) {
      var self = this;
      var hostname = location.hostname;
      var staticPath = '';
      if (hostname != 'dev.allchips.com') {
        //生产需要带上static
        staticPath = '/static/site';
      }
      var format = options.format ? options.format : "jpg,jpeg,png,gif,bmp,pdf,txt,zip,rar,7z";
      //html5 方式在IE10会报拒绝访问
      var uploader = new plupload.Uploader({
        runtimes: "html5,gears,flash,silverlight,html4",
        browse_button: options.id,
        multipart: true,
        flash_swf_url: staticPath + "/js/libs/plupload/moxie.swf",
        silverlight_xap_url: staticPath + "/js/libs/plupload/moxie.xap",
        multi_selection: false, //是否允许选择多个文件
        filters: {
          mime_types: [
            {
              //只允许上传xlsx
              title: "files",
              extensions: format
            }
          ],
          max_file_size: "20mb", //最大只能上传20mb的文件
          prevent_duplicates: true //不允许选取重复文件
        },
        preinit: {
          Init: function (up, info) {
            //IE8\IE9效果处理
          }
        },
        Browse: function (up) {
          // Called when file picker is clicked
        },
        init: {
          FilesAdded: function (up, files) {
            var flag = true;
            if (format) {
              //格式判断
              var a = format.replace(/\,/g, '|').replace(/\./g, '');
              for (var index = 0; index < files.length; index++) {
                var element = files[index];
                var fileFormat = element.name.split('.').pop().toLocaleLowerCase();
                if (!new RegExp(a).test(fileFormat)) {
                  flag = false;
                  base.utils.confirm('选择文件格式有误！');
                  break;
                }
              }
            }
            if (flag && options.before && options.before(files)) {
              $(".loading-tip").removeClass("hide");
              $(".loading-tip").find(".loading-content span").text("处理中,请稍后...");
              // $('#'+id).text('上传中...');
              self.getSign(up, files, options);
            } else {
            }
            // uploader.start();
          },
          PostInit: function (up, files) {
          },
          FileUploaded: function (up, file, info) {
            if (info.status == 200) {
              var result = {};
              result.staticUrl = file.staticUrl; //绝对路径
              result.myName = file.myName; //上传的名字
              result.relativeUrl = file.relativeUrl; //相对路径
              result.name = file.name;
              $(".loading-tip").addClass("hide");
              options.callback(result);
            } else {
              $(".loading-tip")
                .find(".loading-content span")
                .text("上传失败，请稍后再试！");
              setTimeout(function () {
                $(".loading-tip").addClass("hide");
              }, 2000);
            }
          },
          Error: function (up, err) {
            $(".loading-tip")
              .find(".loading-content span")
              .text("上传失败，请稍后再试！");
            setTimeout(function () {
              $(".loading-tip").addClass("hide");
            }, 2000);
          }
        }
      });
      uploader.init();
    },
    getSign: function (up, files, options) {
      var self = this;
      base.utils.MyAjax("/website/api/upload/signature", { callback: options.path.slice(1) }, "post", function (res) {
        if (res.code == 0) {
          for (var i = 0, len = files.length; i < len; i++) {
            var file = files[i];
            var myDate = new Date();
            var second = myDate.getTime();
            file.myName = res.data.prefix + "." + file.name.split('.').pop().toLocaleLowerCase();
            file.relativeUrl = res.data.callback ? res.data.callback.split(".com")[1] + file.myName : options.path + file.myName;
            file.staticUrl = res.data.callback ? options.ossPicPath + res.data.callback.split(".com")[1] + file.myName : options.ossPicPath + options.path + file.myName;
            new_multipart_params = {
              key: file.relativeUrl.slice(1),
              policy: res.data.policy,
              OSSAccessKeyId: res.data.key,
              success_action_status: "200", //让服务端返回200,不然，默认会返回204
              signature: res.data.signature,
              // secure: true
              // 'callback':res.data.callback
            };
            //
            var hostUrl = res.data.callback ? res.data.callback.split(".com")[0] + ".com" : "https://allchips-img.oss-cn-shanghai.aliyuncs.com";
            up.setOption({
              url: hostUrl,
              multipart_params: new_multipart_params
            });
            up.start();
          }
        }
      }
      );
    }
  };
  module.exports = aliUploadByIE;
});
