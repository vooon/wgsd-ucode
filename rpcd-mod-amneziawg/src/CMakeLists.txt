cmake_minimum_required(VERSION 2.8.12)
PROJECT(rpcd-mod-amneziawg)
ADD_DEFINITIONS(-Os -Wall -Werror --std=gnu99 -g3 -Wmissing-declarations)

SET(SOURCES wireguard.c api.c)

ADD_LIBRARY(rpcd-mod-amneziawg SHARED ${SOURCES})

SET_TARGET_PROPERTIES(rpcd-mod-amneziawg PROPERTIES OUTPUT_NAME amneziawg PREFIX "")
INSTALL(TARGETS rpcd-mod-amneziawg LIBRARY DESTINATION lib/rpcd)
