# H5中video的事件的触发顺序是怎样的
## w3school给出的答案
1.loadstart //浏览器开始寻找指定的视频   
2.durationchange //视频时长变更时触发  
3.loadedmetadata //加载视频元数据后触发（如时长、尺寸（仅视频）以及文本轨道）  
4.loadeddata //加载完当前帧但是还没有足够数据播放下一帧时触发  
5.progress //浏览器正在下载指定的音频/视频时   
6.canplay //当浏览器能够开始播放指定的音频/视频时  
7.canplaythrough //当浏览器预计能够在不停下来进行缓冲的情况下持续播放指定的音频/视频时  

来源：  
1.[w3school](https://www.w3school.com.cn/tags/av_event_loadstart.asp)  
2.[w3schools英文网站](https://www.w3schools.com/tags/av_event_loadstart.asp)

## 实践检验
### 代码
```
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <style>

    video {
      width: 600px;
      height: 300px;
    }
  </style>
</head>

<body>
  <video src="xxx.mp4" controls></video>
</body>

</html>
<script>
  //当浏览器开始寻找指定的音频/视频时，会发生 loadstart 事件。即当加载过程开始时
  document.querySelector('video').addEventListener('loadstart', () => {
    console.log('loadstart');
  })
  //当浏览器正在下载指定的音频/视频时，会发生 progress 事件
  document.querySelector('video').addEventListener('progress', () => {
    console.log('progress');
  })
  //当指定音频/视频的时长数据发生变化时，发生 durationchange 事件
  document.querySelector('video').addEventListener('durationchange', () => {
    console.log('durationchange');
  })
  //当指定的音频/视频的元数据已加载时，会发生 loadedmetadata 事件。(时长、尺寸（仅视频）以及文本轨道)
  document.querySelector('video').addEventListener('loadedmetadata', () => {
    console.log('loadedmetadata');
  })
  //当当前帧的数据已加载，但没有足够的数据来播放指定音频/视频的下一帧时，会发生 loadeddata 事件
  document.querySelector('video').addEventListener('loadeddata', () => {
    console.log('loadeddata');
  })
  //当浏览器能够开始播放指定的音频/视频时，发生 canplay 事件
  document.querySelector('video').addEventListener('canplay', () => {
    console.log('canplay');
  })
  //当浏览器预计能够在不停下来进行缓冲的情况下持续播放指定的音频/视频时，会发生 canplaythrough 事件
  document.querySelector('video').addEventListener('canplaythrough', () => {
    console.log('canplaythrough');
  })
  document.querySelector('video').addEventListener('play', () => {
    console.log('play');
  })
</script>
```
### 实测结果  
1.loadstart  
2.progress  
3.durationchange  
4.loadedmetadata  
5.loadeddata  
6.canplay
7.canplaythrough  
实测发现progress事件是第二个发生的，这点与w3c描述不一致
