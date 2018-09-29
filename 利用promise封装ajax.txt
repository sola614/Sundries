export async function myhttp(options = {}) {
  let data = await new Promise((resolve, reject) => {
    //do something
    //resolve =>成功操作，在promise的then操作捕捉参数
    //reject =>返回一个带有拒绝原因reason参数的Promise对象，定义失败操作 ，在promise的catch操作捕捉

    //eg 封装ajax
    //普通xhr封装
    //var xhr = new XMLHttpRequest()
       // xhr.open("POST", url, true)
       // xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        //xhr.onreadystatechange = function () {
       //     if (this.readyState === 4) {
       //         if (this.status === 200) {
       //             resolve(JSON.parse(this.responseText), this)
       //         } else {
        //            var resJson = { code: this.status, response: this.response }
         //           reject(resJson, this)
        //        }
        //    }
     //   }
      //  xhr.send(JSON.stringify(data))
    //微信小程序请求封装
    //wx.request({
      //url: options.url,
      //data: Object.assign({}, options.data),
      //method: options.methods || 'GET',
      //header: {
        //'Content-Type': 'application/json'
      //},
      //success: resolve,
      //fail: reject
    //});
  });
  return data;
}
export default {
  myhttp
}

const {myhttp} = require('filePath');

//用于vue
import Vue from 'vue'
Vue.prototype.$http = myhttp;
