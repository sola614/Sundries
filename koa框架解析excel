const axios = require("axios");
const XLSX = require("xlsx");

module.exports = async function (ctx, next) {
  //获取excel文件并进行解析
  const workbook  = await axios.get(`${url}`,{
    responseType:`arraybuffer`
  }).then(response => {
    const wb =  XLSX.read(response.data, {type:'buffer'});
    return wb;
  });
  // 获取 Excel 中所有表名
  const sheetNames = workbook.SheetNames; // 返回 ['sheet1', 'sheet2']
  // 根据表名获取对应某张表
  const worksheet = workbook.Sheets[sheetNames[0]];
  
  await ctx.render('htmlFilePath', {

  });
  await next();
};



