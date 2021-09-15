// 下载iconfont文件,需要在package.json添加
// "icons": [
//     {
//       "project": "projectName",
//       "aliUrl": "iconfontUrl",
//       "dir": "保存的路径"
//     }
//   ]
const chalk = require('chalk')
const _ = require('lodash')
const path = require('path')
const fs = require('fs')
const request = require('request')
const wget = require('wget')

const FONT_FILE_TYPE_EOT = 'eot'
const FONT_FILE_TYPE_WOFF = 'woff'
const FONT_FILE_TYPE_TTF = 'ttf'
const FONT_FILE_TYPE_SVG = 'svg'
const packageJsonPath = path.dirname(__dirname) + '/package.json'
let icons = require(packageJsonPath).icons
if (Array.isArray(icons)) {
  for (let item of icons) {
    //进入判断文件是否存在
    fs.access(`${path.resolve(item.dir)}/iconfont.css`, fs.constants.F_OK, (err) => {
      if (err) {
        console.log(`iconfont.css不存在，开始创建生成`);
        down(icons)
      }
    });
  }
}
fs.watchFile(packageJsonPath, {
  interval: 2000
}, (cur, prv) => {
  if (cur.mtime != prv.mtime) {
    console.log(`iconfont配置更新`)
    delete require.cache[require.resolve(packageJsonPath)]
    icons = require(packageJsonPath).icons
    down(icons)
  }
})


const postUrl = (_url, fn) => {
  request(_url, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      fn(body)
    } else {
      console.error('=======gen Icon error========')
      if (response && response.statusCode === 404) {
        console.error('iconfont 路径丢失了！')
      } else {
        console.log(error + '')
      }
    }
  })
}

const downIcon = (iconUrl, dir) => {
  postUrl('https:' + iconUrl, (chunk) => {
    let form = 0
    let to = form
    let urlList = []
    let count = 0
    while (form !== -1 && to !== -1) {
      count++
      if (count > 3000) throw new Error("gen icon failed")
      form = to + 1
      form = chunk.indexOf("url(", form)
      to = chunk.indexOf(")", form + 1)
      if (form !== -1 && to !== -1) {
        urlList.push(chunk.substr(form + 5, to - form - 6))
      }
    }
    urlList = _.uniq(urlList.map(_url => _url.split("#")[0]))
    count = urlList.length
    urlList.forEach(_url => {
      let __url = _url.split("?")[0]
      let {
        ext
      } = path.parse(__url)
      let fileName = "iconfont" + ext
      let filePath = path.join(dir, fileName)
      fs.existsSync(filePath) && fs.unlinkSync(filePath)
      if (__url[0] !== '/') return
      let download = wget.download("https:" + __url, filePath, {})
      chunk.split(_url).join("")
      download.on('error', function (err) {
        throw err
      })
    })
    urlList.forEach(_url => {
      let strs = _url.split('?')[0].split('.')
      let type = strs[strs.length - 1]
      if (_url[0] !== '/') return
      chunk = chunk.replace(_url, './iconfont.' + type)
      chunk = chunk.replace(_url, './iconfont.' + type)
    })
    //判断文件夹是否存在
    fs.stat(dir, (err, stats) => {
      if (err) {
        console.log(`文件夹${dir}不存在，开始创建`);
        fs.mkdir(dir, err => {
          if (err) {
            console.log(`创建文件夹${dir}失败，请重试或手动创建`);
          } else {
            fs.writeFileSync(path.join(dir, 'iconfont.css'), chunk)
            console.log(`生成iconfont成功`);
          }
        })
      } else {
        fs.writeFileSync(path.join(dir, 'iconfont.css'), chunk)
        console.log(`生成iconfont成功`);
      }
    })
  })
}

function down(icons) {
  for (let item of icons) {
    downIcon(item.aliUrl, path.resolve(item.dir))
  }
}

module.exports = {
  down
}
