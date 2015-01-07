TOP_DIR := $(shell pwd)
PKG_DIR := $(TOP_DIR)/pkg
DL_DIR := $(TOP_DIR)/download
BUILD_DIR := $(TOP_DIR)/build
STAGING_DIR := $(TOP_DIR)/staging
TARGET_DIR := $(TOP_DIR)/target
TOOLS_DIR := $(TOP_DIR)/tools

DEPS :=

.PHONY: _all
all: _all

include $(PKG_DIR)/*.mk

_all: $(DEPS)

