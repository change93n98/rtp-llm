export ROCM_TOOLKIT_PATH=/opt/dtk
export TF_ROCM_AMDGPU_TARGETS=gfx936
export GCC_HOST_COMPILER_PATH=/usr/bin/gcc

##################### 第一部分：链接python3.10 #####################
# 1. 创建目标目录
DESTDIR="/opt/conda310"
LIBPYTHON_SRC="/usr/lib/x86_64-linux-gnu/libpython3.10.so"
PYTHON_SRC="/usr/bin/python3.10"

echo "==> 创建目录 $DESTDIR"
mkdir -p "$DESTDIR"
mkdir -p "$DESTDIR/bin"
mkdir -p "$DESTDIR/lib"

# 2. 建立软链接
cd "$DESTDIR/bin"

echo "==> 建立 python3 软链接"
ln -sf "$PYTHON_SRC" python3

echo "==> 建立 python 软链接"
ln -sf "$PYTHON_SRC" python

echo "==> 链接创建完成，结果如下： "
ls -l "$DESTDIR"

cd "$DESTDIR/lib"
echo "==> 建立 libpython3.10.so 软链接"
ln -sf "$LIBPYTHON_SRC" libpython3.10.so

##################### 第二部分：升级 GCC 到 12 #####################
export DEBIAN_FRONTEND=noninteractive

echo "==> 更新 apt 索引"
apt-get update -qq

echo "==> 安装 GCC-12 及相关工具链"
apt-get install -y --no-install-recommends \
    gcc-12 g++-12 build-essential \
    libstdc++-12-dev libc6-dev lld binutils gdb

echo "==> 设置 gcc/g++ 默认版本为 12"
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 50 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-12

echo "==> 验证版本"
gcc --version | head -n1
g++ --version | head -n1

# ##################### 第三部分：安装 Bazelisk #####################
# BAZELISK_SRC="/home/downloads/bazelisk-linux-amd64"
# BAZELISK_DST="/usr/local/bin/bazelisk"

# echo "==> 创建 Bazelisk 软链接"
# ln -sf "$BAZELISK_SRC" "$BAZELISK_DST"
# chmod +x "$BAZELISK_DST"

# echo "==> 固定 Bazel 版本为 6.4.0 并验证"
# export USE_BAZEL_VERSION=6.4.0
# "$BAZELISK_DST" --version