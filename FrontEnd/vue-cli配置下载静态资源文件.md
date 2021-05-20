# 方法一：使用public文件夹
 在vue-cli中新建一个static文件夹，把对应文件放入，然后在.vue文件中使用`process.env.BASE_URL/static`或`/static`文件路径即可实现下载功能
# 方法二：使用url-loader
在随意目录建立static文件夹，把对应文件放入，然后在`vue.config.js`中的`configureWebpack`添加以下代码：
```
configureWebpack: config => {
    if (Array.isArray(config.module.rules)) {
      config.module.rules.push(
        {
          test: /\.(xlsx)$/,
          use: [
            {
              loader: 'url-loader',
              // options: {
              //   limit: 8192
              // }
            }
          ]
        }
      )
    }
}
```
然后在`.vue`文件中使用`require`或`import`引入即可，如`this.path = require('../static/test.xlsx')`   
PS1：此方法是利用url-loader得到一串base64代码，下载的时候需要自己使用download属性更改文件名   
PS2：configureWebpack中的test格式是根据你的项目需要下载什么格式就填什么格式，这里的.xlsx仅作为参考   
PS3：可以在`vue.config.js`中自定义目录别名，如`@static`，操作是在`chainWebpack`添加如下代码：
```
chainWebpack: config => {
  config.resolve.alias.set('@static', path.resolve('static'))
}
```
