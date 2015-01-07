KICAD_APP_REVISION ?= 5054
KICAD_LIB_REVISION ?= last:1
KICAD_DOC_REVISION ?= last:1
KICAD_FP_REVISION = last:1

KICAD_SUFFIX ?= -$(KICAD_APP_REVISION)
KICAD_PREFIX ?= /usr/local/share/kicad/kicad$(KICAD_SUFFIX)

# Use https under bazaar to retrieve repos because this does not require a
# launchpad.net account.  Whereas lp:<something> requires a launchpad account.
# https results in read only access.
KICAD_BZR_REPO_BASE = https://code.launchpad.net

KICAD_APP_REPO = $(KICAD_BZR_REPO_BASE)/~kicad-product-committers/kicad/product
KICAD_LIB_REPO = $(KICAD_BZR_REPO_BASE)/~kicad-product-committers/kicad/library
KICAD_DOC_REPO = $(KICAD_BZR_REPO_BASE)/~kicad-developers/kicad/doc

KICAD_FP_REPO_BASE = https://github.com/KiCad
KICAD_FP_REPOS_LIST_URL = https://api.github.com/orgs/KiCad/repos?per_page=2000

KICAD_BUILD_DIR = $(BUILD_DIR)/kicad
KICAD_APP_BUILD_DIR_NAME = kicad.bzr
KICAD_APP_BUILD_DIR = $(KICAD_BUILD_DIR)/$(KICAD_APP_BUILD_DIR_NAME)
KICAD_LIB_BUILD_DIR_NAME = kicad-lib.bzr
KICAD_LIB_BUILD_DIR = $(KICAD_BUILD_DIR)/$(KICAD_LIB_BUILD_DIR_NAME)
KICAD_DOC_BUILD_DIR_NAME = kicad-doc.bzr
KICAD_DOC_BUILD_DIR = $(KICAD_BUILD_DIR)/$(KICAD_DOC_BUILD_DIR_NAME)
KICAD_FP_BUILD_DIR_NAME = kicad-fp
KICAD_FP_BUILD_DIR = $(KICAD_BUILD_DIR)/$(KICAD_FP_BUILD_DIR_NAME)

KICAD_APP_STAGING_DIR = $(STAGING_DIR)/kicad-app
KICAD_LIB_STAGING_DIR = $(STAGING_DIR)/kicad-lib
KICAD_DOC_STAGING_DIR = $(STAGING_DIR)/kicad-doc

KICAD_APP_OPTS = \
    -DCMAKE_INSTALL_PREFIX=$(KICAD_PREFIX) \
    -DCMAKE_INSTALL_RPATH=$(KICAD_PREFIX)/lib \
    -DwxWidgets_USE_STATIC=OFF \
    -DBUILD_GITHUB_PLUGIN=ON

KICAD_LIB_OPTS = \
    -DCMAKE_INSTALL_PREFIX=$(KICAD_PREFIX)

KICAD_DOC_OPTS = \
    -DCMAKE_INSTALL_PREFIX=$(KICAD_PREFIX)

KICAD_LIB_REAL_REVISION = $(shell cd $(KICAD_LIB_BUILD_DIR); bzr revno)
KICAD_DOC_REAL_REVISION = $(shell cd $(KICAD_DOC_BUILD_DIR); bzr revno)

DEPS += \
    kicad-packaged

# TODO Add cmake and wxWidgets as dependencies

.PHONY: kicad-packged

kicad-packaged: \
    $(TARGET_DIR)/.kicad-app.packaged \
    $(TARGET_DIR)/.kicad-lib.packaged \
    $(TARGET_DIR)/.kicad-doc.packaged \
    $(TARGET_DIR)/.kicad-fp.packaged

# KiCAD application rules

$(KICAD_BUILD_DIR)/.kicad-app.checkedout:
	if [ -d $(KICAD_APP_BUILD_DIR)/.bzr ]; then \
	    cd $(KICAD_APP_BUILD_DIR) && \
	    bzr up -r $(KICAD_APP_REVISION) ; \
	else \
	    mkdir -p $(KICAD_BUILD_DIR) && \
	    cd $(KICAD_BUILD_DIR) && \
	    bzr checkout -r $(KICAD_APP_REVISION) $(KICAD_APP_REPO) $(KICAD_APP_BUILD_DIR_NAME) ; \
	fi && \
	touch $(@)

$(KICAD_BUILD_DIR)/.kicad-app.configured: $(KICAD_BUILD_DIR)/.kicad-app.checkedout
	mkdir -p $(KICAD_APP_BUILD_DIR)/build && \
	cd $(KICAD_APP_BUILD_DIR)/build && \
	PATH=$(TOOLS_DIR)/usr/bin:$(WXWIDGETS_STAGING_DIR)$(WXWIDGETS_PREFIX)/bin:$(PATH) $(CMAKE) $(KICAD_APP_OPTS) ../ && \
	touch $(@)

$(KICAD_BUILD_DIR)/.kicad-app.built: $(KICAD_BUILD_DIR)/.kicad-app.configured
	cd $(KICAD_APP_BUILD_DIR)/build && \
	PATH=$(TOOLS_DIR)/usr/bin:$(WXWIDGETS_STAGING_DIR)$(WXWIDGETS_PREFIX)/bin:$(PATH) $(MAKE) && \
	touch $(@)

$(STAGING_DIR)/.kicad-app.installed: $(KICAD_BUILD_DIR)/.kicad-app.built
	cd $(KICAD_APP_BUILD_DIR)/build && \
	DESTDIR=$(KICAD_APP_STAGING_DIR) $(MAKE) install && \
	touch $(@)

$(TARGET_DIR)/.kicad-app.packaged: $(STAGING_DIR)/.kicad-app.installed
	mkdir -p $(TARGET_DIR) && \
	tar czf $(TARGET_DIR)/kicad-app$(KICAD_SUFFIX).tar.gz \
	    -C $(KICAD_APP_STAGING_DIR) $(KICAD_PREFIX:/%=%) \
	    -C $(WXWIDGETS_STAGING_DIR) $(WXWIDGETS_PREFIX:/%=%)/lib --exclude='wx' \
	    --owner root --group root --mode=g-w,o-w && \
	touch $(@)

# KiCAD library rules

$(KICAD_BUILD_DIR)/.kicad-lib.checkedout:
	if [ -d $(KICAD_LIB_BUILD_DIR)/.bzr ]; then \
	    cd $(KICAD_LIB_BUILD_DIR) && \
	    bzr up -r $(KICAD_LIB_REVISION) ; \
	else \
	    mkdir -p $(KICAD_BUILD_DIR) && \
	    cd $(KICAD_BUILD_DIR) && \
	    bzr checkout -r $(KICAD_LIB_REVISION) $(KICAD_LIB_REPO) $(KICAD_LIB_BUILD_DIR_NAME) ; \
	fi && \
	touch $(@)


$(KICAD_BUILD_DIR)/.kicad-lib.configured: $(KICAD_BUILD_DIR)/.kicad-lib.checkedout
	mkdir -p $(KICAD_LIB_BUILD_DIR)/build && \
	cd $(KICAD_LIB_BUILD_DIR)/build && \
	PATH=$(TOOLS_DIR)/usr/bin:$(PATH) $(CMAKE) $(KICAD_LIB_OPTS) ../ && \
	touch $(@)

$(STAGING_DIR)/.kicad-lib.installed: $(KICAD_BUILD_DIR)/.kicad-lib.configured
	cd $(KICAD_LIB_BUILD_DIR)/build && \
	DESTDIR=$(KICAD_LIB_STAGING_DIR) $(MAKE) install && \
	touch $(@)

$(TARGET_DIR)/.kicad-lib.packaged: $(STAGING_DIR)/.kicad-lib.installed
	mkdir -p $(TARGET_DIR) && \
	tar czf $(TARGET_DIR)/kicad-lib$(KICAD_SUFFIX)-$(KICAD_LIB_REAL_REVISION).tar.gz \
	    -C $(KICAD_LIB_STAGING_DIR) $(KICAD_PREFIX:/%=%) \
	    --owner root --group root --mode=g-w,o-w && \
	touch $(@)

# KiCAD documentation rules

$(KICAD_BUILD_DIR)/.kicad-doc.checkedout:
	if [ -d $(KICAD_DOC_BUILD_DIR)/.bzr ]; then \
	    cd $(KICAD_DOC_BUILD_DIR) && \
	    bzr up -r $(KICAD_DOC_REVISION) ; \
	else \
	    mkdir -p $(KICAD_BUILD_DIR) && \
	    cd $(KICAD_BUILD_DIR) && \
	    bzr checkout -r $(KICAD_DOC_REVISION) $(KICAD_DOC_REPO) $(KICAD_DOC_BUILD_DIR_NAME) ; \
	fi && \
	touch $(@)


$(KICAD_BUILD_DIR)/.kicad-doc.configured: $(KICAD_BUILD_DIR)/.kicad-doc.checkedout
	mkdir -p $(KICAD_DOC_BUILD_DIR)/build && \
	cd $(KICAD_DOC_BUILD_DIR)/build && \
	PATH=$(TOOLS_DIR)/usr/bin:$(PATH) $(CMAKE) $(KICAD_DOC_OPTS) ../ && \
	touch $(@)

$(STAGING_DIR)/.kicad-doc.installed: $(KICAD_BUILD_DIR)/.kicad-doc.configured
	cd $(KICAD_DOC_BUILD_DIR)/build && \
	DESTDIR=$(KICAD_DOC_STAGING_DIR) $(MAKE) install && \
	touch $(@)

$(TARGET_DIR)/.kicad-doc.packaged: $(STAGING_DIR)/.kicad-doc.installed
	mkdir -p $(TARGET_DIR) && \
	tar czf $(TARGET_DIR)/kicad-doc$(KICAD_SUFFIX)-$(KICAD_DOC_REAL_REVISION).tar.gz \
	    -C $(KICAD_DOC_STAGING_DIR) $(KICAD_PREFIX:/%=%) \
	    --owner root --group root --mode=g-w,o-w && \
	touch $(@)

# KiCAD footprint libraries rules

$(KICAD_BUILD_DIR)/.kicad-fp.checkedout:
	mkdir -p $(KICAD_FP_BUILD_DIR) && \
	cd $(KICAD_FP_BUILD_DIR) && \
	curl $(KICAD_FP_REPOS_LIST_URL) 2>/dev/null \
	    | grep full_name | grep pretty | sed -r  's:.+ "KiCad/(.+)",:\1:' | sort -u \
	    > fp-repos.list && \
	ORPHANED=`find . -maxdepth 1 -name '*.pretty' -type d -printf '%f\\n' | sort -u | comm -23 - fp-repos.list` && \
	for ORPH in $$ORPHANED ; do \
	    echo "Removing orphaned library $$ORPH" ; \
	    rm -rf ./$$ORPH ; \
	done && \
	for LIB in `cat fp-repos.list` ; do \
	    if [ -e $$LIB ]; then \
	        echo "Updating $$LIB..." && \
	        ( cd $$LIB && git pull ) ; \
	    else \
	        git clone $(KICAD_FP_REPO_BASE)/$$LIB $$LIB ; \
	    fi ; \
	done && \
	for LIB in `cat fp-repos.list` ; do \
	    ( cd $$LIB && git log -1 --format=format:'%cd' --date=short && echo "" ) ; \
	done \
	    | sort -r | head -n 1 > fp-repos.date && \
	touch $(@)

$(TARGET_DIR)/.kicad-fp.packaged: $(KICAD_BUILD_DIR)/.kicad-fp.checkedout
	mkdir -p $(TARGET_DIR) && \
	cd $(KICAD_FP_BUILD_DIR) && \
	tar czf $(TARGET_DIR)/kicad-fp$(KICAD_SUFFIX)-$(shell cat $(KICAD_FP_BUILD_DIR)/fp-repos.date | sed -e 's/-//g').tar.gz \
	    *.pretty --exclude=.git --transform='s:^:$(KICAD_PREFIX:/%=%)/share/kicad/footprints/:' \
	    --owner root --group root --mode=g-w,o-w && \
	( echo "export KISYSMOD=$(KICAD_PREFIX)/share/kicad/footprints" && \
	    echo "export KIGITHUB=$(KICAD_FP_REPO_BASE)" && \
	    echo "export KISYS3DMOD=$(KICAD_PREFIX)/share/kicad/modules/packages3d" ) \
	    > $(TARGET_DIR)/kicad-fp$(KICAD_SUFFIX).env && \
	touch $(@)
