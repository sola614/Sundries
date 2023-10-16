# 进制转换
```
N进制转十进制
console.log(parseInt(val,N))
十进制转N进制
console.log(val.toString(N))
```

# 统计字符串出现次数
```
const str = 'ABCabc'
const s = 'A'
const reg = new RegExp(s,'ig')
console.log(str.split(reg).length-1);
```

# 去重&从小到大输出
```

const arr = [42,543,256,2,4,3,2,1]
//ES6
const arr2 = Array.from(new Set(arr))
//ES5
function unique(arr){
  for(let i = 0;i<arr.length;i++){
    for(let j = i+1;j<arr.length;j++){
      if(arr[i]===arr[j]){
        arr.splice(i,1)
      }
    }
  }
  return arr
}
//arr2 = unique(arr)
//排序
arr2.sort((a,b)=>{
  return a-b
})
console.log(arr2.join('\n'))
```

# 检查一个字符串不能有长度大于N的子串重复
```
const str = '021Abc9Abc1'//Abc有重复，所以返回true是正确答案
function check(str, num) {
 // return /.*(...)(.*\1)/.test(str) //纯正则
  for (let i = 0; i < str.length - (num - 1); i++) {
    // for循环
    //const substring = str.slice(i + num)//截取剩余字符串
    //for (let j = 0; j < substring.length - (num - 1); j++) {
    //  if (str.slice(i, i + num) === substring.slice(j, j + num)) {
    //    return true
    //  }
    //}
    //用indexOf
    const substring = str.slice(i, i + num);
    if (str.indexOf(substring, i + num) !== -1) {
      return true;
    }
  }
  return false
}
console.log(check(str, 3))
```
