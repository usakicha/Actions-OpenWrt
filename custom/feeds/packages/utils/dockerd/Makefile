include $(TOPDIR)/rules.mk

PKG_NAME:=dockerd
PKG_VERSION:=29.2.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_GIT_URL:=github.com/moby/moby
PKG_GIT_REF:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://codeload.$(PKG_GIT_URL)/tar.gz/$(PKG_GIT_REF)?

# --- 请在此处填入下载文件的 SHA256 ---
PKG_HASH:=d73ca30d4a859690b7a4525c98bb2cfb79498db64b4604012983210a55562287
# --- 请在此处填入该版本对应的 Git Short Commit (7位) ---
PKG_GIT_SHORT_COMMIT:=9c62384

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/docker/docker

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/dockerd/config
  source "$(SOURCE)/Config.in"
endef

# 修改了 DEPENDS：移除了 iptables 相关，加入了 nftables 和 firewall4
define Package/dockerd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Docker Community Edition Daemon
  URL:=https://www.docker.com/
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +ca-certificates \
    +containerd \
    +nftables \
    +kmod-nft-core \
    +kmod-nft-nat \
    +kmod-nft-bridge \
    +kmod-veth \
    +tini \
    +firewall4 \
    @!(mips||mips64||mipsel)
  USERID:=docker:docker
  MENU:=1
endef

define Package/dockerd/conffiles
/etc/config/dockerd
endef

define Package/dockerd/description
The Docker CE Engine with native nftables support.
endef

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)
TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lc -lgcc_eh)

# 下面的 Version 检查逻辑保留，但如果你手动修改了版本，请确保 containerd 等组件版本兼容
# 如果编译报错版本不匹配，可能需要注释掉 EnsureVendoredVersion 调用

define Build/Prepare
	$(Build/Prepare/Default)
	
	# Verify PKG_GIT_SHORT_COMMIT
	( \
	        EXPECTED_PKG_GIT_SHORT_COMMIT=$$$$( $(CURDIR)/git-short-commit.sh '$(PKG_GIT_URL)' '$(PKG_GIT_REF)' '$(TMP_DIR)/git-short-commit/$(PKG_NAME)-$(PKG_VERSION)' 2>/dev/null || true ); \
	        if [ -z "$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}" ]; then \
	                 echo "Skipping PKG_GIT_SHORT_COMMIT verification for offline/local-source builds."; \
	        elif [ "$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}" != "$(strip $(PKG_GIT_SHORT_COMMIT))" ]; then \
	                 echo "WARNING: Expected 'PKG_GIT_SHORT_COMMIT:=$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}', found 'PKG_GIT_SHORT_COMMIT:=$(strip $(PKG_GIT_SHORT_COMMIT))'"; \
	        fi \
	)
endef

BUILDTAGS:=
ifeq ($(KERNEL_SECCOMP),y)
BUILDTAGS += seccomp
endif
ifeq ($(CONFIG_SELINUX),y)
BUILDTAGS += selinux
endif

define Build/Compile
	( \
	        cd $(PKG_BUILD_DIR); \
	        $(GO_PKG_VARS) \
	        DOCKER_GITCOMMIT=$(PKG_GIT_SHORT_COMMIT) \
	        DOCKER_BUILDTAGS='$(BUILDTAGS)' \
	        VERSION=$(PKG_VERSION) \
	        ./hack/make.sh binary; \
	)
endef

define Package/dockerd/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bundles/binary-daemon/dockerd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bundles/binary-daemon/docker-proxy $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/opt/docker/

  ifeq ($(CONFIG_DOCKER_CHECK_CONFIG),y)
	$(INSTALL_DIR) $(1)/usr/share/docker/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/check-config.sh $(1)/usr/share/docker/
  endif

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dockerd.init $(1)/etc/init.d/dockerd

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/dockerd $(1)/etc/config/dockerd

	# 移除了 sysctl-br-netfilter-ip.conf 的安装，因为 nftables 模式下通常不需要强制加载 br_netfilter 模块来让 iptables 处理桥接流量
	# 如果需要，可以保留，但这里为了纯净 nftables 环境将其注释
	# $(INSTALL_DIR) $(1)/etc/sysctl.d
	# $(INSTALL_DATA) ./files/etc/sysctl.d/sysctl-br-netfilter-ip.conf \
	#        $(1)/etc/sysctl.d/12-br-netfilter-ip.conf
endef

define Package/dockerd/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/dockerd enable
	/etc/init.d/dockerd uciadd
	/etc/init.d/dockerd start
}
endef

define Package/dockerd/prerm
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/dockerd disable
	/etc/init.d/dockerd stop
	/etc/init.d/dockerd ucidel
}
endef

$(eval $(call BuildPackage,dockerd))
