#!/bin/bash

####设置自己的阿里云DDNS信息
aliddns_name="***"								#子域名, 例如abc.def.com, 这里填abc
aliddns_domain="****.***"							#域名, 例如abc.def.com, 这里填def.com
aliddns_ak="******"								#access-key-id
aliddns_sk="******"								#access-key-secret
aliddns_type="A"								#A是IPV4, AAAA是IPV6
#################################

####获取本机IPV4的网址
####手动测试选择一个
#ipv4_url="http://v4.ipv6-test.com/api/myip.php"
ipv4_url="http://ipv4.icanhazip.com"
#################################

####获取本机IPV6的网址
####手动测试选择一个
#ipv6_url="http://v6.ip.zxinc.org/getip"
#ipv6_url="http://v6.ipv6-test.com/api/myip.php"
ipv6_url="http://ipv6.icanhazip.com"
#ipv6_url="http://v4v6.ipv6-test.com/api/myip.php"
#################################

####CPU类型，目前仅支持arm64和amd64
#cpu="arm64"
cpu="amd64"
#################################


#####################################
####以下内容非必要不要修改###########
#####################################

####若未安装阿里云cli，则安装阿里云cli
cg=$(aliyun version 2>&1)
cg=${cg:0:1}
if ! [[ "$cg" -gt 0 ]] 2>/dev/null; then
		echo 下载阿里cli
		wget https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-$cpu.tgz
		echo 解压
		tar xzvf aliyun-cli-linux-latest-amd64.tgz
		echo 复制到系统文件夹
		cp aliyun /usr/local/bin
		echo cli初始化设置
		aliyun configure set \
	  --profile akProfile \
	  --mode AK \
	  --region cn-hangzhou \
	  --access-key-id $aliddns_ak \
	  --access-key-secret $aliddns_sk
	  echo 安装阿里云cli结束
fi
 
####获取本地ip地址
if [ "$aliddns_type" == "AAAA" ]; then
	ip=`wget -q -O - $ipv6_url`
elif [ "$aliddns_type" == "A" ]; then
	ip=`wget -q -O - $ipv4_url`
else
	echo 解析类型设置错误，退出。。。
	exit 1
fi
echo "本地IP地址：$ip"

####读取阿里云解析记录
echo "读取阿里云解析记录：$aliddns_name.$aliddns_domain"
#server_ip=`/root/aliyun alidns  DescribeDomainRecords --DomainName $aliddns_domain --RRKeyWord $aliddns_name --Type AAAA | grep -E "Value" | cut -d '"' -f4`
text=`/root/aliyun alidns  DescribeDomainRecords --DomainName $aliddns_domain --RRKeyWord $aliddns_name --Type $aliddns_type`
server_ip=`echo $text  | grep -Eo '"Value": "[0123456789abcdef:]+"' | cut -d'"' -f4`
recordid=`echo $text  | grep -Eo '"RecordId": "[0-9]+"' | cut -d':' -f2 | tr -d '"'`
echo "读取到解析记录：$server_ip"
echo "读取到recordid：$recordid"


####根据阿里云解析记录的结果处理事件
if [ "$server_ip" = "" ]; then
	#添加解析记录
	echo "未找到有效记录，准备添加记录。。。"
	echo "添加解析记录：$aliddns_name.$aliddns_domain，$ip"
	server_ip=`aliyun alidns AddDomainRecord --DomainName $aliddns_domain --RR $aliddns_name --Type $aliddns_type --Value $ip | grep -Eo '"RecordId": "[0-9]+"' | cut -d':' -f2 | tr -d '"'`
	echo "返回ID：$server_ip"
	if [ "$server_ip" = "" ]; then
		echo "添加解析记录失败！"
		exit 2
	else
		echo "添加解析记录成功！"
		exit 0
	fi
else
	if [ "$server_ip" != "$ip" ]; then
		#升级解析记录
		echo "DNS服务器读取IP与本地IP不匹配，准备修改解析记录。。。"
		echo "修改解析记录：$aliddns_name.$aliddns_domain，$ip"
	    aliyun alidns UpdateDomainRecord --RR $aliddns_name --RecordId $recordid --Type $aliddns_type --Value $ip
		echo "修改完成，尝试再次读取校验。。。"
		sleep 10
		server_ip=`aliyun alidns  DescribeDomainRecords --DomainName $aliddns_domain --RRKeyWord $aliddns_name --Type $aliddns_type | grep -E "Value" | cut -d '"' -f4`
		echo "读取完成，读取IP为：$server_ip"
		
		if [ "$server_ip" == "$ip" ]; then
			echo "修改解析记录成功！"
			exit 0
		else
			echo "修改解析记录失败！"
			exit 3
		fi
	else
		#无需修改解析记录
		echo "DNS服务器读取IP与本地IP匹配，无需上传IP。。。"
		exit 0
	fi
fi
