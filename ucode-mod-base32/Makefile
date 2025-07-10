include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-mod-base32
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/ucode-mod-base32
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ucode base32 module
  DEPENDS:=+libucode
endef

define Package/ucode-mod-base32/description
The base32 plugin provides b32enc and b32dec functions.
endef

define Package/ucode-mod-base32/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode
	$(CP) $(PKG_BUILD_DIR)/base32.so $(1)/usr/lib/ucode/
endef

define Build/Configure
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(FPIC) \
		-Wall -ffunction-sections -Wl,--gc-sections -shared -Wl,--no-as-needed -lbase32 \
		-o $(PKG_BUILD_DIR)/base32.so $(PKG_BUILD_DIR)/ucode_adapter.c
endef

$(eval $(call BuildPackage,ucode-mod-base32))

