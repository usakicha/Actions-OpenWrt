# 引入OpenWrt构建系统的基础规则和函数（如 BuildPackage 等）
include $(TOPDIR)/rules.mk

# ==================== 包元数据 ====================
PKG_NAME:=llama-cpp
PKG_VERSION:=0.0.0_git20260622
PKG_RELEASE:=1

# 使用Git从GitHub主仓库获取源码
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ggml-org/llama.cpp.git
PKG_SOURCE_VERSION:=master
PKG_MIRROR_HASH:=skip

# 包含OpenWrt的包构建框架
include $(INCLUDE_DIR)/package.mk
# 包含CMake构建系统的特定支持
include $(INCLUDE_DIR)/cmake.mk

CMAKE_BINARY_SUBDIR:=build

# ==================== 包定义 ====================
define Package/llama-cpp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Port of Facebook's LLaMA model in C/C++
  URL:=https://github.com/ggml-org/llama.cpp
  DEPENDS:=+libstdcpp +libpthread +libatomic 
endef

define Package/llama-cpp/description
  llama.cpp is a C/C++ library for running large language model (LLM) 
  inference locally, with minimal setup and state-of-the-art performance.
endef

# ==================== 构建配置（智能架构优化） ====================
CMAKE_OPTIONS += \
    -DGGML_NATIVE=OFF \
    -DLLAMA_BUILD_COMMON=ON \
    -DLLAMA_BUILD_TOOLS=ON \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_SERVER=ON \
    -DLLAMA_BUILD_APP=OFF
	-DBUILD_SHARED_LIBS=OFF \
    -DLLAMA_OPENSSL=OFF \
    -DGGML_CURL=OF

# ---- 自动根据CPU架构启用优化选项 ----
# $(ARCH) 是OpenWrt buildroot 内置变量，例如：arm, x86, mips, powerpc 等
# 更详细的判断可用 $(CPU_TYPE)，例如：cortex-a53、x86-64

ifeq ($(ARCH),arm)
    # 所有ARM架构默认开启NEON和FP16加速，多数ARMv7/ARMv8 CPU支持
    CMAKE_OPTIONS += -DGGML_NEON=ON -DGGML_FP16=ON
else ifeq ($(ARCH),aarch64)
    # 纯64位ARM（少见，但保留）
    CMAKE_OPTIONS += -DGGML_NEON=ON -DGGML_FP16=ON
else ifeq ($(ARCH),x86_64)
    # x86-64平台，优先尝试AVX2，如果运行环境不支持需要更细粒度判断
    CMAKE_OPTIONS += -DGGML_AVX2=ON
    # 若需兼容老x86_64 CPU，可改用 SSE42 或关闭所有手动优化，依赖GGML的自动检测
    # CMAKE_OPTIONS += -DGGML_SSE42=ON
else ifeq ($(ARCH),i386)
    # 32位x86（极少数OpenWrt设备）
    CMAKE_OPTIONS += -DGGML_SSE42=ON
else ifeq ($(ARCH),mips)
    # MIPS平台通常无硬件SIMD加速，谨慎操作，一般不加优化
    # 什么都不加，让GGML自行处理（可能回退到纯C）
endif

# 若需更精细控制，可进一步检查CPU_TYPE
# 例如检查 $(CPU_TYPE) 是否包含 "cortex-a7", "cortex-a53" 等
# ifeq ($(CPU_TYPE),cortex-a53)
#     CMAKE_OPTIONS += -DGGML_NEON=ON -DGGML_FP16=ON
# endif
# ==================== 安装规则 ====================
# 指定构建完成后，哪些文件会被复制到固件的根文件系统中
define Package/llama-cpp/install
	# 创建目标目录
	$(INSTALL_DIR) $(1)/usr/bin
	# 安装核心可执行文件
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/bin/llama-cli $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/bin/llama-server $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/bin/llama-bench $(1)/usr/bin/
	# 如果你需要其他工具，可以按以下格式继续添加
	# $(INSTALL_BIN) $(PKG_BUILD_DIR)/build/bin/llama-quantize $(1)/usr/bin/
endef

# 这是构建系统的入口点，将包名传递给 BuildPackage 宏
$(eval $(call BuildPackage,llama-cpp))
