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
思路：对字符串循环遍历截取出N个字符，然后判断剩下的字符串是否还存在相同的
代码：
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

# 十进制数字转二进制并补全
```
const a = 123
console.log(parseInt(a).toString(2).padStart(8,'0'))
```

# 矩阵乘法计算量
```
思路：对规则字符串转化为数组，然后遍历，碰到大写英文单词（根据题目规则）则在队列中放入一个矩阵数据，碰到)则表明前两个需要运算（计算量运算规则是倒数第二个数值相乘*倒数第一个的y参数），然后还要把运算后的矩阵数据放回队列（倒数第二个的x和倒数第一个的y），以此类推最后就可以得到总的计算量
代码：
A是一个50×10的矩阵，B是10×20的矩阵，C是20×5的矩阵 计算(A(BC))的计算量
const arr = ["50 10","10 20","20 5"]
const rule = "(A(BC))"
function sum(){
    const a = rule.split('')
    const queen = []
    index = 0
    let count = 0
    a.map((key)=>{
        if(/[A-Z]/.test(key)){
            //检测到是字母则加入待计算的矩阵数据
            queen.push(arr[index].split(' '))
            index++
        }else if(/\)/.test(key)){
            //检测到)则表示需要进行运算 用倒数第二个的值相乘再乘以最后一个的y值，然后这两个矩阵的最终会得到另一个矩阵，即倒数第二个的x和倒数第一个的y组成一个新矩阵，等待下一次运算
            const last = queen.pop(),last2 = queen.pop()
            count+= last2[0]*last2[1]*last[1]
            queen.push([last2[0],last[1]])
        }
    })
    console.log(count)
}
sum()

```

# 查找兄弟单词
```
思路：先统计每个字符串出现的次数，然后遍历所有单词根据兄弟单词的规则来判断（长度相同，与原单词不相同，单词里每个字母的长度相同）
代码：
// 输出word的兄弟单词长度&&输出第一个单词
let line = "6 cab ad abcd cba abc bca abc 1"
const arr = line.split(' ')
const index = arr.pop() //需要输出的索引
const word = arr.pop() // 需要查找的单词
const words = word.split('')
const obj = {}
//统计出每个字符串出现次数
words.map((w)=>{
    if(obj[w]){
        obj[w]++
    }else{
        obj[w]=1
    }
})
arr.shift() // 去除第一个无用数据
const newArr = []
arr.map((item)=>{
    if(word.length===item.length&&word!==item){
        // 筛选符合个数的字母出来，如果所有字母都符合长度那表示是它的兄弟单词
       const filters =  words.filter((w)=>{
            return item.split(w).length-1 === obj[w]
        })
        if(filters.length===words.length){
            newArr.push(item)
        }

    }
})
console.log(newArr.length)
if(newArr[index-1]){
    newArr.sort()
    console.log(newArr[index-1])
}
```
# 找出两个字符串的最长子串
```
思路：用最短的字符串从0开始截取，然后用最长的字符串去测试，如果存在则说明是一个子串，得到所有的子串后再按照字符串长度排序，最后判断是否有多个相同长度的子串，有则取第一个，没有就是最后一个
代码：
const a = 'efgyiffxoonftmmvd'
const b = 'exwzdcwjsttuhsxrcpzplpnfqxqsqtlfctdkgacejitayoafucmfxxhkxyixxykndchyjc'
let main = a, sub = b
if (b.length < a.length) {
    main = b
    sub = a
}
const newArr = []//记录两个字符串所有的子串
for(let i =0;i<main.length;i++){
    for(let j =i+1;j<=main.length;j++){
        //从第一位开始截取，如果第二个字串有符合条件的就记录下来
        const val = main.slice(i,j)
        if(sub.includes(val)){
            newArr.push(val)
        }
    }
}
// 按照字符串长度升序
newArr.sort((a,b)=>{
    return a.length-b.length
})
const long = newArr.pop()
// 检查是否存在相同长度的子串 如果有，那就取第一个，否则就是最后一个
const newArr2= newArr.filter((str)=>{
    return long.length === str.length
})
// 判断长度
if(newArr2.length){
    console.log(newArr2[0])
}else{
    console.log(long)
}
```
# 称砝码(统计给定的砝码和数量可以称出多少不同的重量数)
```
思路：遍历砝码重量列表与对应数量相乘得出单个砝码的所有组合数据，然后和已有的组合值逐个相加可得到两个不同砝码的组合重量数，最后即可得出不重复的重量数
代码：
const weight = [1,2,3,4,5]
const num = [5,2,5,3,1]
const set = new Set()
set.add(0) //包括0，并且用来计算每个砝码单独的情况
weight.map((n,i)=>{
  const result = Array.from(set)//获取已存储的结果
  const max = num[i]
  for(let j = 0;j<max;j++){
    const w = n*(j+1)
    result.map((item)=>{
      set.add(Number(item)+w) //item已经是前面组合相加的结果，再把当前的加上去即可得到一种新的重量
    })
  }
})
console.log(set.size)
```
# 单向链表
```
思路：每次获取两个数值，先判断值是否已存在，不存在则在指定值后面插入，直到原来整个数组遍历完成！
代码：
const input = '5 2 3 2 4 3 5 2 1 4 3'
const inputArr = input.split(' ')
const count = inputArr.shift() //节点总数
const first = inputArr.shift() //链表开头开头
const del = inputArr.pop() //需要删除的节点
const link = [first]
while (inputArr.length>0) {
  const arr = inputArr.splice(0,2)//删除原数组的前两位并把它的值保存起来
  const checkVal = arr[0]
  const nextHasFlag = link.indexOf(checkVal)
  // 判断链表里不存在这个值则插入
  if (nextHasFlag === -1) {
    const nextIndex = link.indexOf(arr[1])+1 //下一个节点值插入位置
    link.splice(nextIndex,0,checkVal)
  }
}
link.splice(link.indexOf(del),1)
console.log(link.join(' '))
```
# 迷宫问题
```
思路：把输入拆成数组，然后从第一列开始遍历，如果遍历到当前节点是可通行则保存并把它的前后左右都进行判断，直到走到最终节点就输出之前所有的值
代码：
const size = [5, 5]
const inputArr = [[0, 1, 0, 0, 0], [0, 1, 0, 1, 0], [0, 0, 0, 0, 1], [0, 1, 1, 1, 0][0, 0, 0, 0, 0]]
function findway(points = [], x = 0, y = 0) {
  // 超出临界点判断
  if (x < 0 || x === size[0]) return
  if (y < 0 || y === size[1]) return
  const point = `(${x},${y})`//当前坐标
  // 当前左边值为0即表示可以走&&集合没有记录则说明是个新坐标，需要判断它上下左右是否继续可走
  if (inputArr[x][y] === 0 && !points.includes(point)) {
    // 当前已到临界点
    if (x === size[0]-1 && y === size[1]-1) {
      points.map((item) => {
        console.log(point)
      })
      return
    }
    const newPoints = [...points, point] //能走通的坐标集合
    findway(newPoints, x + 1, y)
    findway(newPoints, x - 1, y)
    findway(newPoints, x, y + 1)
    findway(newPoints, x, y - 1)
  }
}
findway()
```

