# daed 额外内核需求检查清单

## 已配置的核心要求 ✅

根据 daed/dae 项目的要求，以下内核配置已在 `.config` 中启用：

### 1. eBPF 基础支持
- [x] `CONFIG_KERNEL_BPF=y`
- [x] `CONFIG_KERNEL_BPF_SYSCALL=y`
- [x] `CONFIG_KERNEL_BPF_JIT=y`
- [x] `CONFIG_KERNEL_HAVE_EBPF_JIT=y`
- [x] `CONFIG_KERNEL_EBPF_JIT=y`

### 2. BTF (BPF Type Format)
- [x] `CONFIG_KERNEL_DEBUG_INFO=y`
- [x] `CONFIG_KERNEL_DEBUG_INFO_BTF=y`
- [x] `CONFIG_KERNEL_DEBUG_INFO_REDUCED=n`

### 3. Cgroups v2 支持
- [x] `CONFIG_KERNEL_CGROUPS=y`
- [x] `CONFIG_KERNEL_CGROUP_BPF=y`
- [x] `CONFIG_KERNEL_CGROUP_PIDS=y`
- [x] `CONFIG_KERNEL_MEMCG=y`
- [x] `CONFIG_KERNEL_MEMCG_SWAP=y`

### 4. 网络 eBPF 支持
- [x] `CONFIG_KERNEL_BPF_EVENTS=y`
- [x] `CONFIG_KERNEL_NET_CLS_BPF=y`
- [x] `CONFIG_KERNEL_NET_ACT_BPF=y`
- [x] `CONFIG_KERNEL_NETFILTER_XT_MATCH_BPF=y`

### 5. XDP 支持
- [x] `CONFIG_KERNEL_XDP_SOCKETS=y`
- [x] `CONFIG_KERNEL_XDP_SOCKETS_DIAG=y`

### 6. BPF 文件系统
- [x] `CONFIG_KERNEL_BPF_FS=y`

### 7. 追踪和调试
- [x] `CONFIG_KERNEL_KPROBE_EVENTS=y`
- [x] `CONFIG_KERNEL_UPROBE_EVENTS=y`
- [x] `CONFIG_KERNEL_FTRACE=y`
- [x] `CONFIG_KERNEL_FUNCTION_TRACER=y`
- [x] `CONFIG_KERNEL_DYNAMIC_FTRACE=y`

## 可能需要的额外配置

根据 daed 的完整功能需求，你可能还需要考虑以下配置：

### 网络功能增强

```bash
# 如果需要更完整的网络功能，可以添加：
CONFIG_KERNEL_NET_SCH_FQ=y              # Fair Queue 调度器
CONFIG_KERNEL_NET_SCH_FQ_CODEL=y        # FQ-CoDel 队列
CONFIG_KERNEL_NET_SCH_CAKE=y            # CAKE 队列管理
CONFIG_KERNEL_TCP_CONG_BBR=y            # BBR 拥塞控制
```

### 连接跟踪

```bash
# 连接跟踪和 NAT
CONFIG_KERNEL_NF_CONNTRACK=y
CONFIG_KERNEL_NF_CONNTRACK_MARK=y
CONFIG_KERNEL_NETFILTER_XT_MARK=y
CONFIG_KERNEL_NETFILTER_XT_TARGET_MARK=y
```

### 安全相关

```bash
# 如果 daed 需要安全相关功能
CONFIG_KERNEL_SECCOMP=y
CONFIG_KERNEL_SECCOMP_FILTER=y
```

## 编译后验证步骤

固件刷入后，通过 SSH 运行以下命令验证：

### 1. 检查 BPF 支持
```bash
# 查看 BPF 文件系统
mount | grep bpf
# 应该看到: none on /sys/fs/bpf type bpf

# 检查内核配置
zcat /proc/config.gz | grep "CONFIG_BPF"
```

### 2. 检查 BTF 支持
```bash
# 查看 BTF vmlinux 文件
ls -lh /sys/kernel/btf/vmlinux
# 应该存在此文件

# 如果安装了 bpftool
bpftool btf dump file /sys/kernel/btf/vmlinux format c | head -20
```

### 3. 检查 Cgroups v2
```bash
# 检查 cgroup2 挂载
mount | grep cgroup2
# 应该看到 cgroup2 文件系统

# 查看可用的 cgroup 控制器
cat /sys/fs/cgroup/cgroup.controllers
```

### 4. 测试 eBPF 程序加载
```bash
# 如果已安装 bpftool
bpftool prog list

# 查看 eBPF map
bpftool map list
```

## daed 软件包安装

daed 本身需要单独安装，因为它不在 OpenWrt 官方源中：

### 方法 1: 使用第三方源

取消 `diy-script.sh` 中的注释：
```bash
git clone https://github.com/daeuniverse/daed-package.git package/daed
```

### 方法 2: 手动安装 IPK

1. 从 [daed releases](https://github.com/daeuniverse/daed/releases) 下载预编译的 IPK
2. 通过 LuCI 或 opkg 命令安装

### 方法 3: 使用 immortalwrt 源

immortalwrt 可能包含 daed 软件包，可以添加到 feeds 中。

## 运行时依赖

daed 运行时还需要：

1. **用户空间工具**
   - `kmod-inet-diag` - 网络诊断
   - `kmod-netlink-diag` - Netlink 诊断
   - `ca-bundle` - CA 证书（已包含）

2. **运行时库**
   - 可能需要特定版本的 glibc 或 musl

3. **权限配置**
   - daed 需要 root 权限运行
   - 需要 CAP_NET_ADMIN 等特权

## 已知限制

1. **内核版本要求**
   - OpenWrt 25.12.5 使用的内核版本应该支持所有必需的 eBPF 特性
   - 建议内核版本 ≥ 5.10（OpenWrt 通常使用 5.15 或更高）

2. **CPU 架构**
   - x86_64 完全支持 eBPF JIT
   - 其他架构可能有限制

3. **内存要求**
   - eBPF 程序需要额外内存
   - 建议至少 512MB RAM（虚拟机至少 1GB）

## 故障排除

### 如果 daed 提示内核特性缺失

1. 检查内核配置：
```bash
zcat /proc/config.gz | grep -i "缺失的特性名称"
```

2. 查看 daed 日志：
```bash
logread | grep daed
```

3. 检查 dmesg 中的 BPF 相关错误：
```bash
dmesg | grep -i bpf
```

### 常见错误

**错误**: "BTF is required but not supported"
**解决**: 确认 `/sys/kernel/btf/vmlinux` 存在，如不存在需重新编译内核

**错误**: "cgroup2 not mounted"
**解决**: 
```bash
mount -t cgroup2 none /sys/fs/cgroup
```

**错误**: "BPF syscall not permitted"
**解决**: 检查系统权限，daed 需要 root 运行

## 总结

当前配置已经包含了 daed 运行所需的**所有核心内核特性**：

✅ eBPF 完整支持
✅ BTF 类型信息
✅ Cgroups v2
✅ XDP 套接字
✅ 网络 BPF 钩子
✅ 追踪和调试支持

主要还需要的是：
1. **安装 daed 软件包本身**（需要从第三方源获取）
2. **验证运行时环境**（按照上述步骤验证）
3. **配置 daed 服务**（根据 daed 文档进行配置）

如果在实际使用中遇到问题，可以根据 daed 的错误提示，参考本文档进行相应的内核配置调整。
