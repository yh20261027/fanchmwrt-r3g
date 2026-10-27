# r3g-extras: meta package that force-selects (via kconfig "select")
# the LuCI protocol UIs and tools needed for this build.
#
# Background: in the pinned FanchmWrt/LuCI feed combination, plain
# "CONFIG_PACKAGE_luci-proto-*=y" entries in the seed .config get dropped
# by `make defconfig` even when all LUCI_DEPENDS are satisfied. Package
# dependencies with the "+" prefix are translated to kconfig "select"
# statements which force the target symbols to y.

include $(TOPDIR)/rules.mk

PKG_NAME:=r3g-extras
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

define Package/r3g-extras
  SECTION:=net
  CATEGORY:=Network
  TITLE:=R3G forced extras (protocol UIs, QR support)
  MAINTAINER:=custom build
  DEPENDS:= \
	+luci-proto-wireguard \
	+luci-proto-qmi \
	+luci-proto-mbim \
	+luci-proto-ncm \
	+luci-proto-3g \
	+libqrencode \
	+qrencode
endef

define Package/r3g-extras/description
  Meta package force-selecting R3G extras via package dependencies:
  WireGuard / QMI / MBIM / NCM / 3G protocol configuration UIs and
  QR code support for WireGuard peer provisioning.
endef

$(eval $(call BuildPackage,r3g-extras))
