<!--
 * @Descripttion: 文件描述
 * @Author: sola.zhang
 * @Date: 2022-03-25 17:07:22
 * @LastEditors: sola.zhang
 * @LastEditTime: 2022-03-25 17:29:39
-->
# 一、按需引入
1、安装`babel-plugin-component`
```
npm install babel-plugin-component -D
yarn add babel-plugin-component -D
```
编辑`babel.config.js`或`.babelrc`
```
//babel.config.js
module.exports = {
  presets: [
    '@vue/cli-plugin-babel/preset',
  ],
  plugins: [
    [
      "component",
      {
        libraryName: "element-ui", //按需引入elementUI
        // styleLibraryName: "~src/theme" //自定义主题(https://element.eleme.cn/#/zh-CN/component/custom-theme#jin-ti-huan-zhu-ti-se)
        styleLibraryName: "theme-chalk",
      }
    ]
  ]
}

//.babelrc
{
  "presets": [["es2015", { "modules": false }]],
  "plugins": [
    [
      "component",
      {
        "libraryName": "element-ui",
        "styleLibraryName": "theme-chalk"
      }
    ]
  ]
}

```
2、新建element-ui.ts
```
//@ts-ignore
import locale from 'element-ui/lib/locale/lang/en'//国际化
import {
  Pagination,
  Dialog,
} from 'element-ui'

const element = {
  install: (Vue: any) => {
    // 调用Vue.use(element) 会自动调用install方法
    Vue.prototype.$ELEMENT = {
      size: 'mini',
      locale
    }
    Vue.use(Pagination);
    Vue.use(Dialog)

    Vue.prototype.$loading = Loading.service
    Vue.prototype.$msgbox = MessageBox
    Vue.prototype.$alert = MessageBox.alert
    Vue.prototype.$confirm = MessageBox.confirm
    Vue.prototype.$prompt = MessageBox.prompt
    Vue.prototype.$notify = Notification
    Vue.prototype.$message = Message
  }
}
export default element
```
3、编辑main.ts
```
...
// import Element from 'element-ui'//全局引入
import element from './element-ui'//按需引入
Vue.use(element)
...
```

# 二、自定义主题   
## 仅替换主题色
1、前往[在线主题生成工具](https://elementui.github.io/theme-chalk-preview)更改需要的颜色，然后下载文件
2、使用
2.1 全局引入
```
import '../theme/index.css'
import ElementUI from 'element-ui'
import Vue from 'vue'

Vue.use(ElementUI)
```
2.2 按需引入，安装`babel-plugin-component`请参照上面按需引入，以下是`.babelrc`配置
```
{
  "plugins": [
    [
      "component",
      {
        "libraryName": "element-ui",
        "styleLibraryName": "~src/theme"//自定义主题相对于 .babelrc 的路径，注意要加 ~，这里theme文件夹路径为src/theme
      }
    ]
  ]
}
```
## 在项目中改变 SCSS 变量
1、新建`element-variables.scss`
```
/* 改变主题色变量 */
$--color-primary: #ea5504 !default;
$--color-text-primary:#ea5504 !default;

/* 改变 icon 字体路径变量，必需，请自行填写正确的路径，SSR渲染有可能路径不对，请注意 */
$--font-path: '~element-ui/lib/theme-chalk/fonts';


@import "~element-ui/packages/theme-chalk/src/index";
```
2、编辑`main.ts`
```
// import Element from 'element-ui'//全局引入
import element from './element-ui'//按需引入
import './styles/element-variables.scss'
Vue.use(element)
```
# 三、Vue-Cli去除console
1、安装`babel-plugin-transform-remove-console`
```
npm install babel-plugin-transform-remove-console -D
yarn add babel-plugin-transform-remove-console -D
```
2、编辑`babel.config.js`
```
module.exports = {
  env: {
    development: {
     
    },
    production: {
      plugins: ['transform-remove-console'] //去除console
    }
  }
}
```

# 完整配置参考
1、`babel.config.js`
```
module.exports = {
  presets: [
    '@vue/cli-plugin-babel/preset',
  ],
  plugins: [
    [
      "component",
      {
        libraryName: "element-ui", //按需引入elementUI
        // styleLibraryName: "~src/theme" //自定义主题(https://element.eleme.cn/#/zh-CN/component/custom-theme#jin-ti-huan-zhu-ti-se)
        styleLibraryName: "theme-chalk",
      }
    ]
  ],
  env: {
    development: {
    },
    production: {
      plugins: ['transform-remove-console'] //去除console
    }
  }
}
```
2、`main.ts`
```
import Vue from 'vue'
import router from './router'
import store from './store'
// import Element from 'element-ui'//全局引入
import element from './element-ui'//按需引入
import './styles/element-variables.scss'
import './styles/index.scss'

Vue.use(element)
new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
```