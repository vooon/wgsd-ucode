include $(TOPDIR)/rules.mk

PKG_NAME:=wgsd-client-ucode
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/wgsd-client-ucode
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=WireGuard Service Discovery Client (ucode)
  PKGARCH:=all
  DEPENDS:=+ucode-mod-ubus +ucode-mod-base32 +ucode-mod-resolv +ucode-mod-socket +rpcd-mod-wireguard +wireguard-tools
endef

define Package/wgsd-client-ucode-awg
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=AmneziaWG Service Discovery Client (ucode)
  PKGARCH:=all
  DEPENDS:=wgsd-client-ucode +rpcd-mod-amneziawg +amneziawg-tools
endef

Build/Compile=

define Package/wgsd-client-ucode/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) ./files/wgsd-client-ucode.sh $(1)/usr/bin/wgsd-client-ucode

	$(INSTALL_DIR) $(1)/usr/share/ucode/wgsd/
	$(INSTALL_DATA) ./files/client.uc $(1)/usr/share/ucode/wgsd/
endef

$(eval $(call BuildPackage,wgsd-client-ucode))
$(eval $(call BuildPackage,wgsd-client-ucode-awg))
