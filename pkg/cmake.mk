CMAKE = $(TOOLS_DIR)/usr/bin/cmake
CMAKE_VERSION = 2.8.12.2
CMAKE_SOURCE_URL = http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz

CMAKE_BUILD_DIR = $(BUILD_DIR)/cmake-$(CMAKE_VERSION)

DEPS += $(TOOLS_DIR)/.cmake.installed

$(DL_DIR)/cmake-$(CMAKE_VERSION).tar.gz:
	mkdir -p $(DL_DIR) && \
	cd $(DL_DIR) && \
	wget $(CMAKE_SOURCE_URL)

$(CMAKE_BUILD_DIR)/.cmake.extracted: $(DL_DIR)/cmake-$(CMAKE_VERSION).tar.gz
	mkdir -p $(BUILD_DIR) && \
	cd $(BUILD_DIR) && \
	tar xzf $(<) && \
	touch $(@)

$(CMAKE_BUILD_DIR)/.cmake.configured: $(CMAKE_BUILD_DIR)/.cmake.extracted
	cd $(CMAKE_BUILD_DIR) && \
	./bootstrap --prefix=$(TOOLS_DIR)/usr && \
	touch $(@)

$(CMAKE_BUILD_DIR)/.cmake.built: $(CMAKE_BUILD_DIR)/.cmake.configured
	cd $(CMAKE_BUILD_DIR) && \
	$(MAKE) && \
	touch $(@)

$(TOOLS_DIR)/.cmake.installed: $(CMAKE_BUILD_DIR)/.cmake.built
	cd $(CMAKE_BUILD_DIR) && \
	$(MAKE) install && \
	touch $(@)
