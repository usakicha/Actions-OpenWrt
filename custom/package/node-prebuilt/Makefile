include $(TOPDIR)/rules.mk

PKG_NAME:=node-prebuilt
PKG_VERSION:=24.15.0
PKG_RELEASE:=1

# ==== 【选项 1】官方 glibc 版本（你的原需求） ====
PKG_SOURCE:=node-v$(PKG_VERSION)-linux-arm64.tar.xz
PKG_SOURCE_URL:=https://nodejs.org/dist/v$(PKG_VERSION)/

# ==== 【选项 2】非官方 musl 版本（在 OpenWrt 强烈推荐） ====
# 如果你的 OpenWrt 是标准的 musl libc 系统，请注释掉上面的两行，取消注释下面两行：
# PKG_SOURCE:=node-v$(PKG_VERSION)-linux-arm64-musl.tar.xz
# PKG_SOURCE_URL:=https://unofficial-builds.nodejs.org/download/release/v$(PKG_VERSION)/

# 跳过哈希校验（便于测试，生产建议生成并填入真实 sha256sum）
PKG_HASH:=skip

# 自动推导解压后的目录名 (通过两次 basename 自动去掉 .tar.xz)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(basename $(basename $(PKG_SOURCE)))

# 避免 OpenWrt 工具链强行 Strip 导致预编译的二进制文件损坏
RESTRICT:=strip

include $(INCLUDE_DIR)/package.mk

define Package/node-prebuilt
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Node.js (Precompiled binary)
  # 在此处追加了 +libpthread (同时建议带上 +librt 和 +libatomic 防范后续其他底层依赖报错)
  DEPENDS:=@aarch64 +libstdcpp +libpthread +librt +libatomic
  URL:=https://nodejs.org/
endef

define Package/node-prebuilt/description
  Node.js precompiled binary for arm64.
endef

# 跳过源码配置和编译阶段
define Build/Configure
endef

define Build/Compile
endef

define Package/node-prebuilt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	
	# 拷贝 npm/npx 所需的全局依赖包
	$(CP) $(PKG_BUILD_DIR)/lib/node_modules $(1)/usr/lib/
	
	# 安装 node 主程序 (自动赋予 0755 权限)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/node $(1)/usr/bin/
	
	# 重建 npm、npx 和 corepack 软链接，指向对应模块
	ln -sf ../lib/node_modules/npm/bin/npm-cli.js $(1)/usr/bin/npm
	ln -sf ../lib/node_modules/npm/bin/npx-cli.js $(1)/usr/bin/npx
	ln -sf ../lib/node_modules/corepack/dist/corepack.js $(1)/usr/bin/corepack
endef

$(eval $(call BuildPackage,node-prebuilt))
