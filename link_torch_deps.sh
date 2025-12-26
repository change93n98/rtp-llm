#!/usr/bin/env bash

# 文件名: create_torch_rocm_links.sh
# 用法: source create_torch_rocm_links.sh

# — 1. 记录原目录
__orig_pwd="$PWD"

# — 2. 容错: set -e 在 source 时会直接退出 shell, 这里改用“温和”模式
# 如需严格失败, 可自己打开: trap 'echo "失败, 行号: $LINENO"; return 1' ERR

# — 3. 获取 bazelisk output_base
if ! OUTPUT_BASE=$(bazelisk info output_base 2>/dev/null); then
    echo "ERROR: 无法获取 bazelisk output_base" >&2
    return 1 2>/dev/null || exit 1
fi
TARGET_DIR="${OUTPUT_BASE}/external/torch_rocm/torch/lib"

if [[ ! -d $TARGET_DIR ]]; then
    echo "ERROR: 目录不存在: $TARGET_DIR" >&2
    return 1 2>/dev/null || exit 1
fi

# — 4. 定义链接表
declare -A LINKS=(
    [/opt/dtk/lib/librocfft.so]=librocfft.so
    [/opt/dtk/lib/librocsolver.so]=librocsolver.so
    [/home/wheels/libaotriton_v2.so]=libaotriton_v2.so
    [/home/wheels/libnuma.so]=libnuma.so
)

# — 5. 进入目标目录干
cd "$TARGET_DIR" || { echo "cd 失败: $TARGET_DIR" >&2; return 1; }

for target in "${!LINKS[@]}"; do
    linkname=${LINKS[$target]}
    if [[ ! -e $target ]]; then
        echo "WARN: 目标文件不存在, 跳过: $target" >&2
        continue
    fi
    # 已存在同名链接则覆盖
    [[ -L $linkname ]] && rm -f "$linkname"
    ln -s "$target" "$linkname"
done

# — 6. 恢复原目录
cd "$__orig_pwd"
unset __orig_pwd
echo "链接创建完成, 当前目录已经恢复: $PWD"