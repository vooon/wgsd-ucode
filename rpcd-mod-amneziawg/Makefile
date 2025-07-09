include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-amneziawg
PKG_RELEASE=1

PKG_LICENSE:=LGPL-2.1+
PKG_BUILD_FLAGS:=gc-sections

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rpcd-mod-amneziawg
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=AmneziaWG rpcd module
  DEPENDS:=+rpcd +kmod-amneziawg
  MAINTAINER:=Andre Heider <a.heider@gmail.com>
endef

define Package/rpcd-mod-amneziawg/install
	$(INSTALL_DIR) $(1)/usr/lib/rpcd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/rpcd/amneziawg.so \
		$(1)/usr/lib/rpcd/
endef

define Package/rpcd-mod-amneziawg/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || /etc/init.d/rpcd reload
endef

$(eval $(call BuildPackage,rpcd-mod-amneziawg))
