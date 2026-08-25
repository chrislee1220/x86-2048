#!/bin/bash
#
# 自定义脚本 - 在编译前执行
#

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/OpenWrt/OpenWrt-X86/g' package/base-files/files/bin/config_generate

# 修改默认时区
sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate

# 添加额外的软件源（可选）
# echo 'src/gz custom_packages https://your-custom-repo.com/packages' >> repositories.conf

# 确保内核支持 eBPF 和 BTF
echo "CONFIG_KERNEL_BPF=y" >> .config
echo "CONFIG_KERNEL_BPF_SYSCALL=y" >> .config
echo "CONFIG_KERNEL_DEBUG_INFO_BTF=y" >> .config
echo "CONFIG_KERNEL_CGROUP_BPF=y" >> .config

# 下载并集成 daed 相关依赖（如果需要）
# 注意：daed 可能需要从第三方源获取
# git clone https://github.com/daeuniverse/daed-package.git package/daed

echo "自定义脚本执行完成！"
