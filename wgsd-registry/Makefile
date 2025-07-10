include $(TOPDIR)/rules.mk

PKG_NAME:=wgsd-registry
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/wgsd-registry
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=WireGuard Service Discovery Registry (ucode)
  PKGARCH:=all
  DEPENDS:=+ucode-mod-ubus +ucode-mod-base32 +rpcd-mod-wireguard
endef

define Package/wgsd-registry-awg
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=AmneziaWG Service Discovery Registry (ucode)
  PKGARCH:=all
  DEPENDS:=wgsd-registry +rpcd-mod-amneziawg
endef

Build/Compile=

define Package/wgsd-registry/conffiles
/etc/config/wgsd-registry
endef

define Package/wgsd-registry/install
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/wgsd-registry.conf $(1)/etc/config/wgsd-registry

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/wgsd-registry.init $(1)/etc/init.d/wgsd-registry

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) ./files/wgsd-registry.sh $(1)/usr/bin/wgsd-registry

	$(INSTALL_DIR) $(1)/usr/share/ucode/wgsd/
	$(INSTALL_DATA) ./files/zone.uc $(1)/usr/share/ucode/wgsd/
endef

$(eval $(call BuildPackage,wgsd-registry))
$(eval $(call BuildPackage,wgsd-registry-awg))
