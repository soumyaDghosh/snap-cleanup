# Set default variables
SCRIPT_NAME = snap-cleanup.sh
SCRIPT_PATH = $(CURDIR)/$(SCRIPT_NAME)

# Directories for installation
LOCAL_BIN = $(HOME)/.local/bin
SYSTEM_BIN = /usr/local/bin

# Check for sudo
ifeq ($(shell id -u), 0)
    INSTALL_DIR = $(SYSTEM_BIN)
else
    INSTALL_DIR = $(LOCAL_BIN)
endif

# Target to install the script
install:
	@echo "Installing $(SCRIPT_NAME) to $(INSTALL_DIR)"
	@mkdir -p $(INSTALL_DIR)
	@install -Dm 755 $(SCRIPT_PATH) $(INSTALL_DIR)/snap-cleanup
	@echo "$(SCRIPT_NAME) has been installed to $(INSTALL_DIR)"

# Target to uninstall the script
uninstall:
	@echo "Uninstalling $(SCRIPT_NAME) from $(INSTALL_DIR)"
	@rm -f $(INSTALL_DIR)/snap_cleanup
	@echo "$(SCRIPT_NAME) has been uninstalled"

# Target to show the help message
help:
	@echo "Usage:"
	@echo "  make install   Install the script"
	@echo "  make uninstall Uninstall the script"
	@echo "  make help      Show this help message"
