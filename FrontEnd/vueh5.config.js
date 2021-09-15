// H5端使用
const fs = require('fs')
const path = require('path');
const autoprefixer = require('autoprefixer');
const pxtorem = require('postcss-pxtorem');
if (process.env.NODE_ENV === 'development') {
  require('./build/iconfont')
}

// 是否为生产环境
const isProduction = process.env.NODE_ENV !== 'development';
// 本地环境是否需要使用cdn
const devNeedCdn = false
// cdn链接
const cdn = {
  // cdn：模块名称和模块作用域命名（对应window里面挂载的变量名称）
  externals: {
    vue: 'Vue',
    vuex: 'Vuex',
    'vue-router': 'VueRouter',
    'nprogress': 'NProgress',
    'axios': 'axios'
  },
  // cdn的css链接
  css: [
    '/css/nprogress.min.css'
  ],
  // cdn的js链接
  js: [
    '/js/vue.global.prod.js',
    '/js/vuex.global.prod.js',
    '/js/vue-router.global.prod.js',
    '/js/nprogress.min.js',
    '/js/axios.min.js'
  ]
}

module.exports = {
  publicPath: '/', //vue-router使用history模式并有二级路由时，这里要填绝对路径，不可为空，否则二级路由刷新显示不正常
  outputDir: 'dist',
  productionSourceMap: false,
  lintOnSave: false,
  chainWebpack: config => {
    config.resolve.alias.set('@', path.resolve('src'))
    // 防止多页面打包卡顿
    config.plugins.delete('named-chunks')
    // 修复HMR
    config.resolve.symlinks(true)

    // ============注入cdn start============
    config.plugin('html').tap(args => {
      args[0].minify = {
        removeComments: true,
        minifyCSS: true,
        minifyJS: true,
        collapseWhitespace: true
      }
      // 生产环境或本地需要cdn时，才注入cdn
      if (isProduction || devNeedCdn) args[0].cdn = cdn
      return args
    })
    // ============注入cdn start============

  },
  configureWebpack: config => {
    if (process.env.NODE_ENV === 'production') {
      //去除console
      config.optimization.minimizer[0].options.terserOptions.compress.drop_console = true
    }
    // 用cdn方式引入，则构建时要忽略相关资源
    if (isProduction || devNeedCdn) config.externals = cdn.externals
  },
  css: {
    loaderOptions: {
      less: {
        // 若 less-loader 版本小于 6.0，请移除 lessOptions 这一级，直接配置选项。
        lessOptions: {
          modifyVars: {
            //覆盖vant变量
            hack: `;@import "${path.resolve('src')}/styles/variables.less";`,
          },
        },
      },

      postcss: {
        plugins: [
          autoprefixer(),
          //rem适配
          pxtorem({
            rootValue ({
              file
            }) {
              // 修改rootValue
              if (file && file.indexOf('vant') > -1) {
                return 37.5 //Vant UI的设计稿的参照尺寸是375
              } else {
                return 75 //自身是750px
              }
            },
            // rootValue: 37.5,
            propList: ['*']
          })
        ]
      }
    },
  },
  devServer: {
    https: {
      key: fs.readFileSync('./ssl/ssl.key'),
      cert: fs.readFileSync('./ssl/ssl.crt'),
      // ca: fs.readFileSync('/path/to/ca.pem'),
    },
    public: 'dev.example.com',
    port: 9525,
    disableHostCheck: true,
    proxy: {
      '/test/': {
        target: 'http://192.168.0.102'
      },
    }
  }
};
