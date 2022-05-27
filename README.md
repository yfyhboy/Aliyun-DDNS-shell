# Aliyun-DDNS-shell
轻量化的shell脚本实现阿里云DDNS，不依赖docker。  
直接保存在linux主机中，加上crontab定时运行即可。  
支持ubuntu、群晖、debain、PVE等等，只要是linux环境基本都支持。  

## 如何使用  

1. 下载aliyunddns.sh文件  
2. 修改里面的配置信息：  
  - aliddns_name    例如域名是abc.def.com，这个地方就填abc
  - aliddns_domain  例如域名是abc.def.com，这个地方就填def.com
  - aliddns_ak      阿里云的access id
  - aliddns_sk      阿里云的access secret
  - aliddns_type    ipv4就填A，ipv6就填AAAA
  - ipv4_url        把url的拷贝到浏览器，试试是否能获取到ipv4地址，保留一个能用的，剩下加#注释掉
  - ipv6_url        把url的拷贝到浏览器，试试是否能获取到ipv6地址，保留一个能用的，剩下加#注释掉
  - cpu             选择CPU平台，目前支持amd64和arm64
3. 保存文件，并把aliyunDDNS.sh拷贝到主机中，可以用winscp或tftp等，只要拷进去就行  
4. 添加执行权限 chmod +x aliyunDDNS.sh
5. 执行脚本./aliyunDDNS.sh
6. 如果运行成功，设置crontab定时运行，3分钟或5分钟跑一次都可以

## 可能遇到的问题

在windows编辑器里面保存的.sh脚本，有可能不能在linux运行，这是windows文件保存格式的问题。如果用的是notepad++编辑器，在界面右下方有个Windows(CR LF)，双击改成Unix(LF)再保存就可以了，如果是其他编辑器请自行baidu解决
