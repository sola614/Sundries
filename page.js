/**
 * 分页
 */
// html样板 <div id="page" data-totalcount="{{wareData.totalCount}}" data-totalpage="{{wareData.totalPageCount}}" data-pagesize="{{wareData.pageSize}}" data-curpage="{{wareData.pageNo}}" class="fr"></div>
// option参数参考
// {
//   url:String 翻页请求的url
//   pageDom:String 翻页组件的html元素 默认#page 需要在这个元素设置totalcount totalpage pagesize curpage 四个data值用于初始化
//   haspagesize:Boolean 是否添加控制每页显示条数的控件
//   before：Function 请求之前的操作 如获取最新参数等 接收参数为该分页组件的设置参数 即使不做任何处理也必须把该值传回
//   otherParamsKey:String 请求需要添加除页数和每页条数之外的额外参数的key值 如 'exparmas' => {exparmas:params} 此处params的值是另外一个配置传过来的参数 如果等于-1 则表示直接遍历params所有参数作为参数 存在多个参数值设-1
//   params：String|Object 与otherParamsKey配合使用，为传参的value
//   tplDataKey：Stirng 该参数指定swig 渲染传入参数的key值 默认为'list'
//   tplData:String 该参数指定获取ajax回调中response.data[tplData]值 默认'result' 其实就是从哪里获取数据
//   beforeDataInit：Function 该参数可以在渲染模板之前对数据进行处理 接收参数为response 必须把该参数传回
//   dom:String 该参数指定获取到数据后渲染的区域元素 默认#listTbody
//   init:Function 该参数是模板渲染到页面后的回调，可用于按钮的初始化等操作
//   scrollTop：Number 该参数指定渲染模板后页面回滚的高度 默认回到顶部
//   reload :Function 链接跳转方式
// }
// 自定义样式请参照page.css 重写样式
define('js/modules/page', function (require, exports, module) {
  var totalCount = 0;
  var totalPage = 0;
  var pageSize = 0;
  var Page = {};
  var options = {};
  var pageDom = "#page";
  var base = require("./base");
  var swigFilter = require("swigFilter"); //
  Page.init = function (option) {
    options = option;
    pageDom = options.pageDom ? options.pageDom : "#page";
    var page = $(pageDom);
    if (page.length > 0) {
      page.data("option", options);
      //初始化
      totalCount = page.data("totalcount");
      totalPage = page.data("totalpage");
      pageSize = page.data("pagesize");
      if (totalCount <= 0 || !totalCount) {
        page.html("").addClass("hide");
        return;
      }
      if (totalCount <= pageSize) {
        // return;
      }
      var html = "";
      if (options.haspagesize) {
        html +=
          '<div class="fl totalcount">共' +
          totalCount +
          '条,每页显示</div><div class="fl"><select name="pagesize" class="page-size">';
        if (pageSize == 20) {
          html +=
            '<option value="20" checked>20</option><option value="50">50</option>';
        } else {
          html +=
            '<option value="20">20</option><option value="50" checked>50</option>';
        }
        html += "</select></div>";
      } else {
        html = '<div class="fl totalcount">共' + totalCount + "条</div>";
      }
      var prevBtnHtml = "<div class='page-prev-btn fl page-ctl-btn disabled'>上一页</div>";
      var nextBtnHtml = "<div class='page-next-btn fl page-ctl-btn disabled'>下一页</div>";
      html += prevBtnHtml;
      html += '<div class="page-nav fl">';
      var curPage = parseInt(page.data("curpage"));
      if (totalPage <= 10) {
        for (var i = 0; i < totalPage; i++) {
          html += "<span>" + (i + 1) + "</span>";
        }
      } else {
        for (var i = 0; i < 7; i++) {
          html += "<span>" + (i + 1) + "</span>";
        }
        html += '<span class="other">...</span><span>' + totalPage + "</span>";
      }
      html += "</div>";
      html += nextBtnHtml;
      page.html(html).removeClass("hide");
      if (curPage != 1) {
        this.updatePage(page.data("curpage"));
        // $('.page-prev-btn').removeClass('disabled');
      } else {
        $(pageDom + " .page-nav span")
          .eq(curPage - 1)
          .addClass("cur");
      }
      Page.resetBtn(curPage);
      // if (totalCount > 1) {
      //   $('.page-next-btn').removeClass('disabled');
      // }
      // var _this=this;
      //分页选择
      $(pageDom + " .page-size").change(function () {
        var pd = $(this).parents(".page").length > 0 ? $(this).parents(".page") : $(this).parents("#page");
        pd.data('pagesize', $(this).val())
        Page.getData(this, 1);
        return;
        var pageSize = $(this).val();
        var pd = $(this).parents(".page").length > 0 ? $(this).parents(".page") : $(this).parents("#page");
        options = pd.data("option");
        pageDom = options.pageDom ? options.pageDom : "#page";
        var sendData = {
          pageSize: pd.data("pagesize"),
          pageNo: 1
        };
        if (options.before && typeof options.before === "function") {
          options = options.before(options);
        }
        if (options.otherParamsKey == -1) {
          //遍历params作为额外参数
          for (var key in options.params) {
            if (options.params.hasOwnProperty(key)) {
              sendData[key] = options.params[key];
            }
          }
        } else if (options.otherParamsKey) {
          sendData[options.otherParamsKey] = options.params;
        } else {
          sendData.extraParam = options.params;
        }
        base.utils.MyAjax(
          options.url,
          sendData,
          "post",
          function (response) {
            if (response.code == 0) {
              require.async("swig", function () {
                // swigFilter.setPicUrl(swig);
                var tpls = swig.compile(options.tpl);
                var tplDataKey = options.tplDataKey ?
                  options.tplDataKey :
                  "list";
                var tplData = options.tplData ? options.tplData : "result";
                var obj = {};
                if (options.beforeDataInit) {
                  response = options.beforeDataInit(response);
                }
                obj[tplDataKey] = response.data[tplData];
                var __html = tpls(obj);
                var dom = options.dom ? options.dom : "#listTbody";
                $(dom).html(__html);
                pd.data("totalcount", response.data.totalCount);
                pd.data("totalpage", response.data.totalPageCount);
                pd.data("pagesize", response.data.pageSize);
                typeof options.init === "function" &&
                  options.init(response.data);
                Page.updatePage(1);
                $("html ,body").animate({
                  scrollTop: options.scrollTop ? options.scrollTop : 0
                },
                  300
                );
              });
            }
          },
          function (res) {
            $(".loading-tip").addClass("hide");
            base.utils.showTip({
              type: "error",
              con: res.message,
              hasBtn: true
            },
              function () {
                icDialog.close();
              }
            );
          }
        );
      });
      //上一页
      $(pageDom + ' .page-prev-btn').off('click').on('click', function (params) {
        var curIndex = parseInt($(pageDom + ' span.cur').text());
        if (curIndex <= 1 || $(this).hasClass('disabled')) {
          $(this).addClass('disabled');
          return;
        }
        curIndex--;
        Page.getData(this, curIndex);
        // $(pageDom + " .page-nav span").eq(curIndex - 1).trigger('click');
        if (curIndex < totalPage) {
          $(this).siblings('.page-next-btn').removeClass('disabled');
        }
        if (curIndex <= 1) {
          $(this).addClass('disabled');
        }
      });
      //下一页
      $(pageDom + ' .page-next-btn').off('click').on('click', function (params) {
        var curIndex = parseInt($(pageDom + ' span.cur').text());
        if (curIndex >= totalPage || $(this).hasClass('disabled')) {
          $(this).addClass('disabled');
          return;
        }
        curIndex++;
        Page.getData(this, curIndex);
        // $(pageDom + " .page-nav span").eq(curIndex - 1).trigger('click');
        if (curIndex > 1) {
          $(this).siblings('.page-prev-btn').removeClass('disabled');
        }
        if (curIndex >= totalPage) {
          $(this).addClass('disabled');
        }
      });
      Page.pageInit();
    }
  };
  Page.pageInit = function () {
    // var _this=this;
    $(pageDom + " .page-nav span").on("click", function (event) {
      event.preventDefault();
      var page = $(this).text();
      if (page == "...") {
        return;
      }
      // Page.resetBtn(page);
      $(this)
        .addClass("cur")
        .siblings()
        .removeClass("cur");
      Page.getData(this, page);
    });
  };
  Page.getData = function (_this, page) {
    var pd = $(_this).parents(".page").length > 0 ? $(_this).parents(".page") : $(_this).parents("#page");
    options = pd.data("option");
    pageDom = options.pageDom ? options.pageDom : "#page";
    var sendData = {
      pageNo: parseInt(page),
      pageSize: $(pageDom).data("pagesize")
    };
    if (options.reload) {
      if (options.reloadCallback && typeof options.reloadCallback === "function") {
        options.params.page = page;
        options.reloadCallback(options);
        return;
      }
      var arr = [];
      for (var key in options.params) {
        if (options.params.hasOwnProperty(key)) {
          arr.push(key + "=" + options.params[key]);
        }
      }
      arr.push("page=" + page);
      location.href = options.url + "?" + arr.join("&");
      return;
    }
    if (options.before && typeof options.before === "function") {
      options = options.before(options); //请求前的回调，用于获取动态请求参数
    }
    //设置请求的参数
    if (options.otherParamsKey == -1) {
      for (var key in options.params) {
        if (options.params.hasOwnProperty(key)) {
          sendData[key] = options.params[key];
        }
      }
    } else if (options.otherParamsKey) {
      //同时存在 params和extraParam 可在params加上一个extraParam对象
      if (options.otherParamsKey != 'extraParam' && options.params.extraParam) {
        var newParam = {};
        var object = options.params;
        for (var key in object) {
          if (object.hasOwnProperty(key)) {
            if (key == 'extraParam') {
              sendData.extraParam = options.params[key];
            } else {
              newParam[key] = options.params[key];
            }
          }
        }
        sendData[options.otherParamsKey] = newParam;
      } else {
        sendData[options.otherParamsKey] = options.params;
      }

    } else {
      sendData.extraParam = options.params;
    }
    base.utils.MyAjax(
      options.url,
      sendData,
      "post",
      function (response) {
        if (response.code == 0) {
          require.async("swig", function () {
            // swigFilter.allConfig(swig); //添加自定义过滤器
            var tpls = swig.compile(options.tpl); //swig化html模板
            var tplDataKey = options.tplDataKey ? options.tplDataKey : "list"; //注入数据key值
            var tplData = options.tplData ? options.tplData : "result"; //注入数据value
            var obj = {};
            if (options.beforeDataInit && typeof options.beforeDataInit === "function") {
              response = options.beforeDataInit(response); //注入数据前的回调，对返回数据针对性处理
            }
            obj[tplDataKey] = response.data[tplData]; //eg. {list:response.data.result}
            var __html = tpls(obj);
            var dom = options.dom ? options.dom : "#listTbody"; //html模板注入对象
            $(dom).html(__html);
            pd.data("totalcount", response.data.totalCount);
            pd.data("totalpage", response.data.totalPageCount);
            pd.data("pagesize", response.data.pageSize);
            typeof options.init === "function" && options.init(response.data);//模板注入html后的后续操作，如按钮初始化等
            Page.updatePage(page);
            $("html ,body").animate({
              scrollTop: options.scrollTop ? options.scrollTop : 0
            },
              300
            );
          });
        } else {
          Page.updatePage(page);
        }
      },
      function (res) {
        $(".loading-tip").addClass("hide");
        base.utils.showTip({
          type: "error",
          con: res.message,
          hasBtn: true
        },
          function () {
            icDialog.close();
          }
        );
      }
    );
  };
  Page.resetBtn = function (p) {
    if (p <= 1) {
      $('.page-prev-btn').addClass('disabled');
    } else {
      $('.page-prev-btn').removeClass('disabled');
    }
    if (p >= totalPage) {
      $('.page-next-btn').addClass('disabled');
    } else {
      $('.page-next-btn').removeClass('disabled');
    }
  };
  Page.updatePage = function (page) {
    //ajax请求
    var pageHtml = "";
    var p = parseInt(page);

    totalCount = $(pageDom).data("totalcount");
    totalPage = $(pageDom).data("totalpage");
    pageSize = $(pageDom).data("pagesize");
    var startPage = 0;
    var endPage = 0;
    if (totalPage > 10) {
      var mid = Math.floor(totalPage / 2);
      if (p - 3 > 1 && p + 4 < totalPage) {
        pageHtml += '<span>1</span><span class="other">...</span>';
        startPage = p - 3;
        endPage = p + 2;
        if (endPage > totalPage) {
          endPage = totalPage;
        }
        for (var i = startPage; i < endPage; i++) {
          if (i + 1 == p) {
            pageHtml += '<span class="cur">' + (i + 1) + "</span>";
          } else {
            pageHtml += "<span>" + (i + 1) + "</span>";
          }
        }
        if (endPage < totalPage) {
          pageHtml +=
            '<span class="other">...</span><span>' + totalPage + "</span>";
        }
      } else if (p - 3 <= 1 && p + 4 < totalPage) {
        startPage = 0;
        endPage = 7; //p - 4
        for (var i = startPage; i < endPage; i++) {
          if (i + 1 == p) {
            pageHtml += '<span class="cur">' + (i + 1) + "</span>";
          } else {
            pageHtml += "<span>" + (i + 1) + "</span>";
          }
        }
        pageHtml += '<span class="other">...</span><span>' + totalPage + "</span>";
      } else if (p - 3 > 1 && p + 4 >= totalPage) {
        pageHtml += '<span>1</span><span class="other">...</span>';
        startPage = totalPage - 7;
        endPage = totalPage;
        for (var i = startPage; i < endPage; i++) {
          if (i + 1 == p) {
            pageHtml += '<span class="cur">' + (i + 1) + "</span>";
          } else {
            pageHtml += "<span>" + (i + 1) + "</span>";
          }
        }
      }
    } else {
      for (var i = 0; i < totalPage; i++) {
        if (p == i + 1) {
          pageHtml += '<span class="cur">' + (i + 1) + "</span>";
        } else {
          pageHtml += "<span>" + (i + 1) + "</span>";
        }
      }
    }
    $(pageDom + " .page-nav").empty();
    $(pageDom + " .page-nav").html(pageHtml);
    $(pageDom + " .totalcount").text("共" + totalCount + "条");
    this.resetBtn(p);
    this.pageInit();
  };
  module.exports = Page;
});
