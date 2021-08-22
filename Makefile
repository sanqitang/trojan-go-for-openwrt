# Copyright (C) 2020 Lienol
#
# This is free software, licensed under the GNU General Public License v3.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=trojan-go
PKG_VERSION:=0.10.2
PKG_RELEASE:=$(SUBTARGET)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/frainzy1477/trojan-go1.git
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=33f3fd564fcced4845fbb39083fb9b9882bf8b11
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_CONFIG_DEPENDS:= \
	CONFIG_TROJAN_GO_COMPRESS_GOPROXY \
	CONFIG_TROJAN_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/frainzy1477/trojan-go
GO_PKG_BUILD_PKG:=$$(GO_PKG)

GO_PKG_TAGS:=full
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/constant.Version=v$(PKG_VERSION) \
	$(GO_PKG)/constant.Commit=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk


define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=2. Trojan
	DEPENDS:=$$(GO_ARCH_DEPENDS)
	TITLE:=Trojan-go.
endef


define Package/$(PKG_NAME)/description
  Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
endef

define Package/$(PKG_NAME)/config
menu "Configuration"
	depends on PACKAGE_$(PKG_NAME)

config TROJAN_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config TROJAN_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y

endmenu
endef

GEOIP_VER:=202105082211
GEOIP_FILE:=geoip.dat
GEOSITE_VER:=202105082211
GEOSITE_FILE:=geosite.dat


ifeq ($(CONFIG_TROJAN_GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.io
endif


define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_TROJAN_GO_COMPRESS_UPX),y)
	wget -q https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz -O $(DL_DIR)/upx-3.96.tar.xz
	rm -rf $(BUILD_DIR)/upx
	mkdir -p $(BUILD_DIR)/upx
	xz -d -c $(DL_DIR)/upx-3.96.tar.xz | tar -x -C $(BUILD_DIR)/upx
	chmod +x $(BUILD_DIR)/upx/upx-3.96-amd64_linux/upx
	$(BUILD_DIR)/upx/upx-3.96-amd64_linux/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(PKG_NAME)
	wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$(GEOIP_VER)/$(GEOIP_FILE)  -O 2>&1 >1 $(GO_PKG_BUILD_BIN_DIR)/$(GEOIP_FILE)
	wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$(GEOSITE_VER)/$(GEOSITE_FILE)  -O 2>&1 >1 $(GO_PKG_BUILD_BIN_DIR)/$(GEOSITE_FILE)
endif
endef


$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
#$(eval $(call BuildPackage,$(PKG_NAME)-geodata))
