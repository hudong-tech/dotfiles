# iTerm2 工具集

这个目录包含用于SSH连接和iTerm2管理的实用工具脚本。

## 工具列表

### clear-host-keys.sh - SSH主机密钥清除工具

**使用场景**：
- ali-3服务器还原系统后，运行连接脚本出现"REMOTE HOST IDENTIFICATION HAS CHANGED"错误

**用法**：
```bash
# 例：ali-3服务器还原系统后，清除旧的主机密钥
./clear-host-keys.sh 服务器IP地址

# 清除指定端口的主机密钥
./clear-host-keys.sh 服务器IP地址 端口号

# 查看帮助信息
./clear-host-keys.sh
```
