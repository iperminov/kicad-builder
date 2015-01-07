WXWIDGETS_VERSION = 3.0.2
WXWIDGETS_SOURCE_URL = https://sourceforge.net/projects/wxwindows/files/3.0.2/wxWidgets-3.0.2.tar.bz2

WXWIDGETS_OPTS = \
    --with-gtk \
    --with-libpng \
    --with-libjpeg \
    --with-libtiff \
    --with-libxpm \
    --with-libiconv \
    --with-libnotify \
    --with-opengl \
    --with-regex \
    --with-zlib \
    --with-expat \
    --enable-utf8 \
    --enable-intl

WXWIDGETS_PREFIX = $(KICAD_PREFIX)

WXWIDGETS_BUILD_DIR = $(BUILD_DIR)/wxWidgets-$(WXWIDGETS_VERSION)
WXWIDGETS_BUILD_OUTPUT_DIR = $(WXWIDGETS_BUILD_DIR)/buildgtk
WXWIDGETS_STAGING_DIR = $(STAGING_DIR)/wxWidgets

DEPS += $(STAGING_DIR)/.wxWidgets.installed

$(DL_DIR)/wxWidgets-$(WXWIDGETS_VERSION).tar.bz2:
	mkdir -p $(DL_DIR) && \
	cd $(DL_DIR) && \
	wget $(WXWIDGETS_SOURCE_URL)

$(WXWIDGETS_BUILD_DIR)/.wxWidgets.extracted: $(DL_DIR)/wxWidgets-$(WXWIDGETS_VERSION).tar.bz2
	mkdir -p $(BUILD_DIR) && \
	cd $(BUILD_DIR) && \
	tar xjf $(<) && \
	touch $(@)

$(WXWIDGETS_BUILD_DIR)/.wxWidgets.configured: $(WXWIDGETS_BUILD_DIR)/.wxWidgets.extracted
	mkdir -p $(WXWIDGETS_BUILD_OUTPUT_DIR) && \
	cd $(WXWIDGETS_BUILD_OUTPUT_DIR) && \
	../configure --prefix=$(WXWIDGETS_STAGING_DIR)$(WXWIDGETS_PREFIX) $(WXWIDGETS_OPTS) && \
	touch $(@)

$(WXWIDGETS_BUILD_DIR)/.wxWidgets.built: $(WXWIDGETS_BUILD_DIR)/.wxWidgets.configured
	cd $(WXWIDGETS_BUILD_OUTPUT_DIR) && \
	make && \
	touch $(@)

$(STAGING_DIR)/.wxWidgets.installed: $(WXWIDGETS_BUILD_DIR)/.wxWidgets.built
	cd $(WXWIDGETS_BUILD_OUTPUT_DIR) && \
	make install && \
	touch $(@)
