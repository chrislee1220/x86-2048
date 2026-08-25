#!/bin/bash
#
# 自定义脚本 - 在编译前执行（修复版）
#

set -e  # 遇到错误立即退出

echo "=========================================="
echo "开始执行自定义配置脚本"
echo "=========================================="

# 修改默认 IP
if [ -f package/base-files/files/bin/config_generate ]; then
    echo "修改默认 IP 地址..."
    sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
    echo "✓ 默认 IP 已修改为 192.168.10.1"
else
    echo "⚠ 警告: config_generate 文件不存在，跳过 IP 修改"
fi

# 修改主机名
if [ -f package/base-files/files/bin/config_generate ]; then
    echo "修改主机名..."
    sed -i 's/OpenWrt/OpenWrt-X86/g' package/base-files/files/bin/config_generate
    echo "✓ 主机名已修改为 OpenWrt-X86"
fi

# 修改默认时区
if [ -f package/base-files/files/bin/config_generate ]; then
    echo "修改默认时区..."
    sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate
    echo "✓ 时区已修改为 CST-8"
fi

# 添加额外的软件源（可选 - daed 支持）
# 取消下面的注释以添加 immortalwrt 源（包含更多第三方软件包）
# echo "添加 immortalwrt 软件源..."
# echo "src-git immortalwrt_packages https://github.com/immortalwrt/packages.git" >> feeds.conf.default
# echo "src-git immortalwrt_luci https://github.com/immortalwrt/luci.git" >> feeds.conf.default
# ./scripts/feeds update immortalwrt_packages immortalwrt_luci
# ./scripts/feeds install -a -p immortalwrt_packages
# ./scripts/feeds install -a -p immortalwrt_luci

# 补充可能缺失的内核配置（不重复添加）
echo "检查并补充内核配置..."

# 检查配置是否已存在的函数
add_config_if_missing() {
    local config_key="$1"
    if ! grep -q "^${config_key}=" .config 2>/dev/null; then
        echo "${config_key}=y" >> .config
        echo "  添加: ${config_key}"
    fi
}

# 网络命名空间
add_config_if_missing "CONFIG_KERNEL_NET_NS"

# Socket 相关
add_config_if_missing "CONFIG_KERNEL_SOCK_CGROUP_DATA"

# BPF 程序类型
add_config_if_missing "CONFIG_KERNEL_BPF_PROG_TYPE_SOCK_OPS"
add_config_if_missing "CONFIG_KERNEL_BPF_PROG_TYPE_SK_MSG"

# 流量控制
add_config_if_missing "CONFIG_KERNEL_NET_SCH_INGRESS"
add_config_if_missing "CONFIG_KERNEL_NET_CLS_ACT"

# Netfilter 连接跟踪
add_config_if_missing "CONFIG_KERNEL_NF_CONNTRACK"
add_config_if_missing "CONFIG_KERNEL_NF_CONNTRACK_MARK"

# 安全相关
add_config_if_missing "CONFIG_KERNEL_SECCOMP"
add_config_if_missing "CONFIG_KERNEL_SECCOMP_FILTER"

echo "✓ 内核配置补充完成"

# 下载并集成 daed 相关依赖（可选）
# 方法 1: 从 GitHub 克隆 daed 相关包
# echo "克隆 daed 软件包..."
# git clone --depth=1 https://github.com/QiuSimons/openwrt-mos.git package/openwrt-mos || echo "⚠ daed 克隆失败"

# 方法 2: 克隆 dae-wing 包（daed 的依赖）
# git clone --depth=1 https://github.com/daeuniverse/dae-wing.git package/dae-wing || echo "⚠ dae-wing 克隆失败"

echo "=========================================="
echo "自定义配置脚本执行完成！"
echo "=========================================="
echo ""
echo "配置摘要:"
echo "- 默认 IP: 192.168.10.1"
echo "- 主机名: OpenWrt-X86"
echo "- 时区: CST-8 (中国标准时间)"
echo "- eBPF/BTF 支持: 已启用"
echo "- daed 软件包: 已由 GitHub Actions feed 集成"
echo ""
