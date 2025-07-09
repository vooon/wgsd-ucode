# Copyright (C) 2013-2017 OpenWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=prometheus-node-exporter-ucode
PKG_VERSION:=2024.02.07
PKG_RELEASE:=2

PKG_MAINTAINER:=Andre Heider <a.heider@gmail.com>
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

Build/Compile=

define Package/$(PKG_NAME)/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Prometheus node exporter
  PKGARCH:=all
endef

define Collector
  define Package/$(PKG_NAME)-$(1)
    $$(call Package/$(PKG_NAME)/Default)
    TITLE+= ($(2))
    DEPENDS:=$(PKG_NAME) $(3)
  endef

  define Package/$(PKG_NAME)-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/share/ucode/node-exporter/lib
	$$(INSTALL_DATA) ./files/extra/$(1).uc $$(1)/usr/share/ucode/node-exporter/lib/
  endef

  $$(eval $$(call BuildPackage,$(PKG_NAME)-$(1)))
endef

$(eval $(call Collector,amneziawg,AmneziaWG collector,+rpcd-mod-amneziawg))
