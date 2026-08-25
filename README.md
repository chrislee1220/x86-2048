# OpenWrt x86_64 云编译配置

这个仓库配置用于在 GitHub Actions 上自动编译 OpenWrt 25.12.5 x86_64 固件，并已针对 daed 插件优化。

## ✨ 功能特性

- ✅ **存储空间扩容至 2GB** - 足够安装各种插件和应用
- ✅ **完整中文语言包** - LuCI 界面完全汉化
- ✅ **CPU 温度监控** - 实时显示 CPU 温度和系统状态
- ✅ **eBPF 和 BTF 内核支持** - 完整支持 daed 等现代网络工具
- ✅ **自动化编译** - 支持手动触发和定时编译

## 📋 daed 插件内核要求

根据 daed (dae 的 Web 管理界面) 的要求，以下内核特性已启用：

### 核心 eBPF 支持
```
CONFIG_KERNEL_BPF=y                    # BPF 基础支持
CONFIG_KERNEL_BPF_SYSCALL=y            # BPF 系统调用
CONFIG_KERNEL_BPF_JIT=y                # BPF JIT 编译器
CONFIG_KERNEL_EBPF_JIT=y               # eBPF JIT 支持
CONFIG_KERNEL_XDP_SOCKETS=y            # XDP 套接字支持
```

### BTF (BPF Type Format) 支持
```
CONFIG_KERNEL_DEBUG_INFO=y             # 调试信息（BTF 必需）
CONFIG_KERNEL_DEBUG_INFO_BTF=y         # BTF 类型信息
CONFIG_KERNEL_DEBUG_INFO_REDUCED=n     # 完整调试信息
```

### Cgroups v2 支持
```
CONFIG_KERNEL_CGROUPS=y                # Cgroups 基础
CONFIG_KERNEL_CGROUP_BPF=y             # Cgroup BPF 支持
CONFIG_KERNEL_CGROUP_PIDS=y            # 进程控制
CONFIG_KERNEL_MEMCG=y                  # 内存控制
```

### 网络相关
```
CONFIG_KERNEL_BPF_EVENTS=y             # BPF 事件
CONFIG_KERNEL_NET_CLS_BPF=y            # 网络分类器
CONFIG_KERNEL_NET_ACT_BPF=y            # 网络动作
CONFIG_KERNEL_NETFILTER_XT_MATCH_BPF=y # Netfilter BPF 匹配
```

### 追踪和调试
```
CONFIG_KERNEL_KPROBE_EVENTS=y          # Kprobe 事件
CONFIG_KERNEL_UPROBE_EVENTS=y          # Uprobe 事件
CONFIG_KERNEL_FTRACE=y                 # 函数追踪
CONFIG_KERNEL_FUNCTION_TRACER=y        # 函数追踪器
```

## 🚀 使用方法

### 1. Fork 这个仓库

点击页面右上角的 "Fork" 按钮，将仓库 fork 到你的 GitHub 账号。

### 2. 启用 GitHub Actions

1. 进入你 fork 的仓库
2. 点击 "Actions" 标签
3. 如果提示启用 workflow，点击 "I understand my workflows, go ahead and enable them"

### 3. 开始编译

#### 方法一：手动触发编译

1. 进入 "Actions" 标签
2. 点击左侧的 "Build OpenWrt x86_64"
3. 点击右侧的 "Run workflow" 按钮
4. 点击绿色的 "Run workflow" 确认

#### 方法二：Push 触发编译

修改任何文件并 push 到 main 分支，会自动触发编译。

#### 方法三：定时自动编译（可选）

编辑 `.github/workflows/build-openwrt.yml` 文件，取消以下行的注释：

```yaml
schedule:
  - cron: '0 2 * * 0'  # 每周日凌晨2点自动编译
```

### 4. 下载编译好的固件

编译完成后（大约需要 2-4 小时），可以通过以下方式下载：

1. **从 Releases 下载**（推荐）
   - 进入仓库的 "Releases" 页面
   - 下载最新的固件文件

2. **从 Actions Artifacts 下载**
   - 进入 "Actions" 页面
   - 点击对应的 workflow 运行记录
   - 在页面底部的 "Artifacts" 区域下载

## ⚙️ 自定义配置

### 修改默认 IP 地址

编辑 `diy-script.sh` 文件，修改以下行：

```bash
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
```

将 `192.168.10.1` 改为你想要的 IP 地址。

### 添加额外的软件包

编辑 `.config` 文件，添加需要的软件包配置。例如：

```
CONFIG_PACKAGE_luci-app-example=y
CONFIG_PACKAGE_luci-i18n-example-zh-cn=y
```

### 安装 daed 插件

当前仓库的 GitHub Actions 已经自动集成 `openwrt-daede` feed，并在编译时安装 `daed` 与 `luci-app-daede`。

如果你是手动本地编译，才需要自己额外添加对应 feed 或安装 IPK。

## 📝 配置说明

### 存储空间配置

- **内核分区大小**: 32MB
- **根文件系统大小**: 2048MB (2GB)
- **文件系统类型**: EXT4 + SquashFS

### CPU 温度监控

固件已集成以下组件来支持 CPU 温度显示：

- `lm-sensors` - 传感器工具
- `kmod-hwmon-core` - 硬件监控内核模块
- `collectd` - 数据收集守护进程
- `luci-app-statistics` - LuCI 统计界面

首次使用时，在 SSH 中运行 `sensors-detect` 来检测可用的传感器。

### 中文语言包

固件已包含以下模块的中文语言包：

- 基础系统 (base)
- 防火墙 (firewall)
- 软件包管理 (package manager)
- DDNS
- UPnP
- 系统统计 (statistics)

## 🔍 验证 eBPF/BTF 支持

固件刷入后，可以通过 SSH 连接路由器验证：

```bash
# 检查 BPF 文件系统
mount | grep bpf

# 检查内核配置
zcat /proc/config.gz | grep -E "CONFIG_.*BPF|CONFIG_.*BTF"

# 检查 Cgroups v2
mount | grep cgroup2
```

## 🐛 常见问题

### 1. 编译失败

- 检查 Actions 日志，查看具体错误信息
- 可能是网络问题导致下载失败，重新运行 workflow
- 某些软件包可能不兼容，需要调整 `.config`

### 2. 固件无法启动

- 确保使用正确的镜像文件（combined-efi.img.gz）
- x86_64 虚拟机建议分配至少 512MB 内存

### 3. CPU 温度不显示

- 需要硬件支持温度传感器
- 在虚拟机中可能无法正确显示温度
- 运行 `sensors-detect` 并安装检测到的驱动

### 4. daed 无法运行

- 确认已正确安装 daed 软件包
- 检查内核是否支持 eBPF: `zcat /proc/config.gz | grep BPF`
- 确认 BTF 支持: `ls /sys/kernel/btf/vmlinux`

## 📚 参考资料

- [OpenWrt 官方文档](https://openwrt.org/docs/start)
- [daed 项目](https://github.com/daeuniverse/daed)
- [eBPF 文档](https://ebpf.io/)
- [OpenWrt 编译教程](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)

## 📄 许可证

本配置文件基于 OpenWrt 项目，遵循相应的开源许可证。

## ⚠️ 免责声明

本配置仅供学习和研究使用。使用者需自行承担使用本配置编译的固件所产生的任何风险和责任。

---

## 💡 技术说明

### 为什么需要这些内核配置？

1. **eBPF/BTF 支持**：daed 使用 eBPF 技术进行高性能网络处理，需要内核完整支持 eBPF 和 BTF
2. **Cgroups v2**：用于进程隔离和资源控制
3. **XDP 支持**：提供更快的网络数据包处理路径
4. **调试信息**：BTF 需要内核调试信息来理解数据结构

### 编译时间估算

- **首次编译**：约 3-4 小时（需要下载和编译所有依赖）
- **增量编译**：约 1-2 小时（缓存了部分依赖）

### 固件大小

- **压缩后**：约 150-250 MB
- **解压后**：约 2GB（包含扩展的根文件系统）

---

**祝你编译愉快！如有问题，欢迎提交 Issue。**
