#!/usr/bin/expect -f

# 服务器连接脚本模板
puts "==============================================="
puts "               服务器ssh连接工具"
puts "==============================================="

set server_name "服务器名称"
set user "username"
set host "your-server-host.com"
set port "22"
set password "your-password"

# 显示连接信息
puts ""
puts "服务器信息:"
puts "  服务器: $server_name"
puts "  用户名: $user" 
puts "  主机地址: $host"
puts "  端口: $port"
puts ""
puts "正在建立SSH连接..."

# 设置超时
set timeout 30

# 启动SSH连接
spawn ssh -p $port $user@$host

# 处理连接过程
expect {
    "yes/no" { 
        puts "接受主机密钥指纹..."
        send "yes\r"
        exp_continue
    }
    "password:" { 
        puts "输入登录密码..."
        send "$password\r" 
    }
    timeout {
        puts "连接超时 (30秒)"
        puts "请检查网络连接或服务器状态"
        exit 1
    }
}

puts "连接成功！正在进入交互模式..."
puts ""

# 交互模式
interact