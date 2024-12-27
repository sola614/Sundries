#!/bin/sh

# 注意：本脚本只支持qb 4.0.4及以上版本
qb_username="" # 改：该为你的qb登录用户名
qb_password="" # 改：改为你qb登录的密码
qb_web_url="http://127.0.0.1:7896" # 查：改为qb的登录地址，一般可以不改
log_dir="/mnt/logs" # 改：改为你日志运行的路径
rclone_dest="alist:tianyi" # 运行rclone config查看name字段即可；格式就是"XX:"
rclone_dest_quark="alist:quark" # 夸克盘
rclone_dest_cddx="alist:cddx" # 自建网盘
from_dc_tag="" # 存放路径，自动获取
rclone_parallel="32" # rclone上传线程 默认4
pan_save_perfix=/downloads # 网盘保存路径
save_path_prefix=/mnt/usbdisk/downloads #填写本地保存地址前缀，如一个文件保存在"/mnt/usbdisk/downloads/Bangumi/更新中"下需要上传到某网盘目录的/downloads下，则填写"/mnt/usbdisk/downloads"，最终会替换成/downloads，然后保存在对应网盘的"/downloads/Bangumi/更新中"目录下
base_prefix_path="/mnt/usbdisk" # 前缀路径，用于判断路径是否时完整路径，如果用anirss的话路径不完整，无法获取正确的文件路径，需自行填充才可上传
leeching_mode="true"    # 上传完毕并且分享率达到全局设置时自动删除任务
rclone_bwlimit="off" #限制速率 即限制， "08:00,2.5M:off 23:00,off"为8点开始限制为上传2.5m/s下载不限制 23点后不限制
upload_dir_files_flag="false"
upload_dir_files_index=-1
# 定义状态，不推荐修改
unfinished_tag="待上传"
uploading_tag="正在上传"
finished_tag="上传完成"
noupload_tag="无效-不上传"


if [ ! -d ${log_dir} ]
then
	mkdir -p ${log_dir}
fi

startPat=`date +'%Y-%m-%d %H:%M:%S'`  # 时间计算方案
start_seconds=$(date --date="$startPat" +%s);

function qb_login(){
	cookie=$(curl -i --header "Referer: ${qb_web_url}" --data "username=${qb_username}&password=${qb_password}" "${qb_web_url}/api/v2/auth/login" | grep -E -o 'SID=\S{32}')
	if [ -n ${cookie} ]
	then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] 登录成功！cookie:${cookie}" 

	else
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] 登录失败！" 
	fi
}

# 先移除指定tag，后增加自己的tag
function qb_change_hash_tag(){
    file_hash=$1
    fromTag=$2
    toTag=$3
    curl -s -X POST -d "hashes=${file_hash}&tags=${fromTag}" "${qb_web_url}/api/v2/torrents/removeTags" --cookie "${cookie}" # 移除tag
    curl -s -X POST -d "hashes=${file_hash}&tags=${toTag}" "${qb_web_url}/api/v2/torrents/addTags" --cookie "${cookie}" # 新增tag
}
function del_file(){
    path=$1
    rm -rf "${path}"
}
function qb_del(){
    torrent_name=$1
    file_hash=$2
    if [ ${leeching_mode} == "true" ]
    then
        # echo "开始请求接口 $1 $2"
        # 如果需要同时删除文件则加此参数 &deleteFiles=true
        result=$(curl -X POST -d "hashes=${file_hash}&deleteFiles=false" "${qb_web_url}/api/v2/torrents/delete" --cookie ${cookie})
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 删除成功！种子名称:${torrent_name}" >> ${log_dir}/qb.log
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 不自动删除已上传种子" >> ${log_dir}/qb.log
    fi
}
function upload_dir_files(){
    torrent_hash=$1
    upload_dir_files_index=$(($upload_dir_files_index+1)) # 自增
    echo "torrent_hash：${torrent_hash}，torrent_path：${fix_torrent_path}，noLock：${noLock}，上传索引：${upload_dir_files_index}"
    if [ ${upload_dir_files_index} -eq ${files_length} ];then
        echo "当前目录【${fix_torrent_path}】符合要求的文件已全部上传完毕" >> ${log_dir}/qb.log
        upload_dir_files_flag="false"
        rclone_fin
        return
    fi
    # echo "${files}"
    file_name=$(echo "${files}" | jq ".[$upload_dir_files_index] | .name" | sed s/\"//g) # 获取文件名
    echo "原始filename---------------${file_name}"
    file_name=${file_name##*/} #截取最后一个/后的真正的文件名
    echo "替换后filename-------------------${file_name}"
    file_formatter=$(echo "${file_name##*.}") # 获取文件后缀
    formatters=("mkv" "ass" "mp4") # 定义符合的后缀
    if echo "${formatters[@]}" | grep -qw "$file_formatter"; then
        # 符合后缀的文件上传
        echo "开始上传【${fix_torrent_path}】目录中的【${file_name}】" >> ${log_dir}/qb.log
        rclone_copy "${file_name}" "${torrent_hash}" "${fix_torrent_path}/${file_name}"
    else
        echo "当前文件【${file_name}】不符合上传要求，开始上传下一个" >> ${log_dir}/qb.log
        upload_dir_files "${torrent_hash}" "${fix_torrent_path}"
    fi
}
function rclone_copy(){
    torrent_name=$1
    torrent_hash=$2
    torrent_path=$3
    # tag = 待上传
    # 这里执行上传程序
    echo "上传文件路径：【${torrent_path}】" >> ${log_dir}/qb.log
    if [ -f "${torrent_path}" ]
    then
        # echo "[$(date '+%Y-%m-%d %H:%M:%S')] 类型：文件"
        type="file"
    elif [ -d "${torrent_path}" ]
    then
        # echo "[$(date '+%Y-%m-%d %H:%M:%S')] 类型：目录"
        type="dir"
         # 获取文件夹内容
        files=$(curl -s "${qb_web_url}/api/v2/torrents/files?hash=${torrent_hash}" --cookie "${cookie}")
        files_length=$(echo "${files}" | jq '.[] | length' | wc -l)
        if [ ${files_length} -gt 0 ];then
            upload_dir_files_flag="true"
            fix_torrent_path="${torrent_path}"
            upload_dir_files "${torrent_hash}" "${fix_torrent_path}"
            return
        fi
    else
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 文件未知类型，取消上传"
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] 取消上传，原因：文件未知类型" >> ${log_dir}/qb.log
       # tag = 不上传
       if [ ${upload_dir_files_flag} == "true" ];then
            upload_dir_files "${torrent_hash}" "${fix_torrent_path}"
        else
            qb_change_hash_tag ${torrent_hash} ${unfinished_tag} ${noupload_tag}
        fi
       return
    fi    
    # 更改为上传中
    qb_change_hash_tag ${torrent_hash} ${unfinished_tag} ${uploading_tag}

    upload_full_path="${rclone_dest}${from_dc_tag}"
    # 检查字符串中是否包含海贼王则换个目录上传
    if [[ "$from_dc_tag" == *"海贼王"* ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检测到是海贼王资源【${from_dc_tag}】" >> ${log_dir}/qb.log
        # 替换字符串中的'更新中'为'长篇连载'
        output=$(echo "$from_dc_tag" | sed 's/更新中/长篇连载/')
        upload_full_path="${rclone_dest_quark}${output}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 修改后上传路径【${upload_full_path}】" >> ${log_dir}/qb.log
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始上传，类型为【${type}】" >> ${log_dir}/qb.log
    # 执行上传
    if [ ${type} == "file" ]
    then # 这里是rclone上传的方法
        echo "最终上传目录：【${upload_full_path}】" >> ${log_dir}/qb.log
        rclone_copy_cmd=$(rclone -v copy --bwlimit "${rclone_bwlimit}" --transfers ${rclone_parallel} --log-file  ${log_dir}/qbauto_copy.log "${torrent_path}" "${upload_full_path}")
    elif [ ${type} == "dir" ]
    then
		rclone_copy_cmd=$(rclone -v copy --bwlimit "${rclone_bwlimit}" --transfers ${rclone_parallel} --log-file ${log_dir}/qbauto_copy.log "${torrent_path}"/ "${upload_full_path}")
    fi
    # 如果当前为上传文件夹则继续上传下一个
    if [ ${upload_dir_files_flag} == "true" ];then
        upload_dir_files "${torrent_hash}" "${fix_torrent_path}"
        return
    fi
    rclone_fin
}
function rclone_fin(){
    # 上传完成
    echo "上传完成，更改状态，当前torrent_hash：${torrent_hash}"
    # 计算上传时间
    endPat=`date +'%Y-%m-%d %H:%M:%S'`
    end_seconds=$(date --date="$endPat" +%s);
    use_seconds=$((end_seconds-start_seconds));
    use_min=$((use_seconds/60));
    use_sec=$((use_seconds%60))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 上传耗时:${use_min}分${use_sec}秒" >> ${log_dir}/qb.log
    # 大于3s小于20s默认重试（可能是文件夹创建失败导致）
    if [ "$use_min" -eq 0 ] && [ "$use_sec" -gt 3 ] && [ "$use_sec" -lt 20 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 上传时间大于3s小于20s，需重试" >> ${log_dir}/qb.log
        qb_change_hash_tag ${torrent_hash} ${uploading_tag} # 把状态清空
    else
        qb_change_hash_tag ${torrent_hash} ${uploading_tag} ${finished_tag} # 把状态设置为上传完成
        # 发送qq消息
        upload_show_name="${content_path##*/}"
        curl -H "Content-Type:application/json" -s -X POST -d "{\"msgType\":30,\"msg\":\"【${upload_show_name}】已上传完成！耗时:${use_min}分${use_sec}秒\"}" "https://api.meaqua.fun/api/sendMsgV2"
        # curl -H "Content-Type:application/json" -s -X POST -d "{\"msgType\":30,\"msg\":\"【${upload_show_name}】已上传完成！耗时:${use_min}分${use_sec}秒，5分钟后将更新海报版！\",\"qqPojo\":{\"qq_type\":20,\"group_id\":616371493}}" "https://api.meaqua.fun/api/sendMsgV2"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 发送通知成功" >> ${log_dir}/qb.log
        # 刷新media刮削
        # 文件名转义，否则会乱码，系统需要安装xxd包，请提前安装好
        encoded_name=$(printf "$upload_show_name" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
        curl -s "https://api.meaqua.fun/api/reloadMedia?name=$encoded_name"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] reloadMedia执行成功！" >> ${log_dir}/qb.log
    fi

}

function file_lock(){
    $(touch qbup.lock)
}
function can_go_lock(){
    lockStatus=$(ls | grep qbup.lock)
    if [ -z "${lockStatus}" ]
    then
        noLock="1"
        return
    fi
    noLock="0"
}
function file_unlock(){
    $(rm -rf qbup.lock)
}

function doUpload(){
    # 处理路径问题，确保正确上传
    torrentInfo=$1
    i=$2
    echo $2
    echo ${i}
    # IFS保存，因为名字中可能出现多个空格
    OLD_IFS=$IFS
    IFS=$(echo -en "\n\b") # IFS="\n"
    torrent_name=$(echo "${torrentInfo}" | jq ".[$i] | .name" | sed s/\"//g) # 文件名
    fix_torrent_name="${torrent_name}"
    torrent_hash=$(echo "${torrentInfo}" | jq ".[$i] | .hash" | sed s/\"//g) # 文件hash
    save_path=$(echo "${torrentInfo}" | jq ".[$i] | .save_path" | sed s/\"//g) # 存储路径
    # save_path="${save_path/${save_path_prefix//\//\\/}/\/downloads}" #把变量save_path_prefix替换成/downloads
    save_path_prefix2="${save_path_prefix//\//\\/}"
    pan_save_perfix2="${pan_save_perfix//\//\\/}"
    save_path="${save_path/$save_path_prefix2/$pan_save_perfix2}"  #把变量save_path_prefix替换成变量pan_save_perfix
    # echo "上传保存目录：【${save_path}】" >> ${log_dir}/qb.log
    content_path=$(echo "${torrentInfo}" | jq ".[$i] | .content_path" | sed s/\"//g) # 最终完整文件路径（包括重命名后）
    torrent_path="${content_path}" # 这里就是他的本地实际路径，尝试将这里上传上去
    # 如果不是以 $base_prefix_path 开头，则添加 $base_prefix_path
    if [[ "$torrent_path" != ${base_prefix_path}* ]]; then
        torrent_path="${base_prefix_path}${torrent_path}"
    fi
    # 还原IFS
    IFS=$OLD_IFS
    
    #每次只上传一个数据，否则的话，可能会导致多线程的争用问题
    can_go_lock
    if [[ ${noLock} == "1" ]] # 厕所门能开
    then
        # echo "【${torrent_path}】" >> ${log_dir}/qb.log
        file_lock # 锁上厕所门
        from_dc_tag="${save_path}"
        rclone_copy "${torrent_name}" "${torrent_hash}" "${torrent_path}"
    else
        echo '已有程序在上传，退出'
        return # 打不开门，换个时间来
    fi
    file_unlock # 打开厕所门，出去
    echo "运行结束"
    echo "----------------------分割线-----------------------------" >> ${log_dir}/qb.log
}

# 每次只查询一条数据，！！上传一条数据！！
function qb_get_status(){
	qb_login
	completed_torrents_num=$(curl -s "${qb_web_url}/api/v2/torrents/info?filter=completed" --cookie "${cookie}" | jq '.[] | length' | wc -l)
    torrentInfo=$(curl -s "${qb_web_url}/api/v2/torrents/info?filter=completed" --cookie "${cookie}")
    # 用于存储需删除的下标的数组
    deleteNums=()
	# echo "已下载完成总任务数："${completed_torrents_num}
	for((i=0;i<${completed_torrents_num};i++));
	do
	    torrent_name=$(echo "${torrentInfo}" | jq ".[$i] | .name" | sed s/\"//g)
        tag_str=$(curl -s "${qb_web_url}/api/v2/torrents/info?filter=completed" --cookie "${cookie}" | jq ".[$i] | .tags" | sed s/\"//g) # 获取所有标签信息
        curtag=$(echo "${tag_str}" | sed s/\"//g | grep -E -o "${unfinished_tag}") # 筛选待上传
                # curtag=$(curl -s "${qb_web_url}/api/v2/torrents/info?filter=completed" --cookie "${cookie}" | jq ".[$i] | .tags" | sed s/\"//g | grep -E -o "${unfinished_tag}")
        # echo "[$(date '+%Y-%m-%d %H:%M:%S')]qb标签信息：${tag_str}" >> ${log_dir}/qb.log
        # 判断tag_str为空或不包含上传字段
#             if  [ -z "${tag_str}" ] || [[ "${tag_str}" != *"上传"* ]]
#             then
#                 echo "标签信息：${tag_str}" >> ${log_dir}/qb.log
#                 curtag="无上传标签"
# 			fi
        if [ -z "${tag_str}" ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')]【${torrent_name}】符合标签为空情况" >> ${log_dir}/qb.log
            curtag="无上传标签"
        elif [[ "${tag_str}" != *"上传"* ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')]【${torrent_name}】符合标签不包含上传字段情况" >> ${log_dir}/qb.log
            curtag="无上传标签"
        fi
        # 判断curtag是否是空  			
        if [ -z "${curtag}" ]
        then
             curtag="null"
        fi
        # echo "curtag=${curtag}"
        # 判断curtag状态执行相应操作
		if [ ${curtag} == "${unfinished_tag}" ]
		then
            # 执行上传操作
			doUpload "${torrentInfo}" ${i}
            break
        elif [ ${curtag} == "无上传标签" ]
        then
            # 没有标签的更改为待上传
            torrent_hash=$(echo "${torrentInfo}" | jq ".[$i] | .hash" | sed s/\"//g)
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 把【${torrent_name}】状态更改为待上传，此时标签信息：${curtag} --- ${tag_str}" >> ${log_dir}/qb.log
            qb_change_hash_tag ${torrent_hash} ${curtag} ${unfinished_tag}
        else
            curtag=$(echo "${torrentInfo}" | jq ".[$i] | .tags" | sed s/\"//g)
            curtag=$(echo "${curtag}" | sed s/\"//g | grep -E -o "${finished_tag}") # 筛选上传完成
            if [ "${curtag}" == "${finished_tag}" ]
            then
                # 标识为上传完成
                torrent_state=$(echo "${torrentInfo}" | jq ".[$i] | .state" | sed s/\"//g)
                # 等于pausedUP||stoppedUP则表示已达最大分享率或时间到，则删除
                if  [ ${torrent_state} == "pausedUP" ] || [ ${torrent_state} == "stoppedUP" ]
                then
                    # torrent_name=$(echo "${torrentInfo}" | jq ".[$i] | .name" | sed s/\"//g)
                    torrent_hash=$(echo "${torrentInfo}" | jq ".[$i] | .hash" | sed s/\"//g)
                    torrent_ratio=$(echo "${torrentInfo}" | jq ".[$i] | .ratio" | sed s/\"//g)
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检测到${torrent_name}需删除，状态为：${torrent_state}，比率为：${torrent_ratio}" >> ${log_dir}/qb.log
                    deleteNums+=("$i")
                fi
            fi
        fi
	done
    # 删除下标值
	for i in "${deleteNums[@]}";
	do
	    torrent_name=$(echo "${torrentInfo}" | jq ".[$i] | .name" | sed s/\"//g)
	    torrent_hash=$(echo "${torrentInfo}" | jq ".[$i] | .hash" | sed s/\"//g)
	    # echo "[$(date '+%Y-%m-%d %H:%M:%S')] 删除: 【$i】【$torrent_name】【$torrent_hash】"  >> ${log_dir}/qb.log
	    qb_del "${torrent_name}" ${torrent_hash}
	done
}
echo "脚本开始执行"
qb_get_status
