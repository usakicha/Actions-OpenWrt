include $(TOPDIR)/rules.mk

PKG_NAME:=docker
PKG_VERSION:=29.2.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_GIT_URL:=github.com/docker/cli
PKG_GIT_REF:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://codeload.$(PKG_GIT_URL)/tar.gz/$(PKG_GIT_REF)?

# --- 请在此处填入下载文件的 SHA256 ---
PKG_HASH:=f2bdc2b7ee7f7840a4d5b845f6c1fdf8bd7a123bba7cf9f1056220794b07ba9c
# --- 请在此处填入该版本对应的 Git Short Commit (7位) ---
PKG_GIT_SHORT_COMMIT:=0b9d198

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host dockerd
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=$(PKG_GIT_URL)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/docker
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Docker Community Edition CLI
  URL:=https://www.docker.com/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/docker/description
The CLI used in the Docker CE and Docker EE products.
endef

GO_PKG_INSTALL_EXTRA:=\
	cli/compose/schema/data \
	vendor/google.golang.org/protobuf/internal/editiondefaults/editions_defaults.binpb

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)
TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lc -lgcc_eh)

define Build/Prepare
	$(Build/Prepare/Default)
	# 验证 Commit ID 的逻辑保留，但请确保 PKG_GIT_SHORT_COMMIT 填写正确
	( \
	        EXPECTED_PKG_GIT_SHORT_COMMIT=$$$$( $(CURDIR)/../dockerd/git-short-commit.sh '$(PKG_GIT_URL)' '$(PKG_GIT_REF)' '$(TMP_DIR)/git-short-commit/$(PKG_NAME)-$(PKG_VERSION)' 2>/dev/null || true ); \
	        if [ -z "$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}" ]; then \
	                echo "Skipping PKG_GIT_SHORT_COMMIT verification for offline/local-source builds."; \
	        elif [ "$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}" != "$(strip $(PKG_GIT_SHORT_COMMIT))" ]; then \
	                echo "WARNING: Expected 'PKG_GIT_SHORT_COMMIT:=$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}', found 'PKG_GIT_SHORT_COMMIT:=$(strip $(PKG_GIT_SHORT_COMMIT))'. proceeding anyway for manual build."; \
	        fi \
	)
endef

define Build/Compile
	( \
	        cd $(PKG_BUILD_DIR); \
	        $(GO_PKG_VARS) \
	        GITCOMMIT=$(PKG_GIT_SHORT_COMMIT) \
	        VERSION=$(PKG_VERSION) \
	        ./scripts/build/binary; \
	)
endef

define Package/docker/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/docker $(1)/usr/bin/
endef

$(eval $(call BuildPackage,docker))
