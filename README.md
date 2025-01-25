## A Bash script using KDialog for cleaning up datas and disabled snaps from your system

Bash Script Using KDialog for Cleaning Up Data and Disabled Snaps from Your System

This script helps clean up old revisions of disabled snaps and their associated data from your system. It uses KDialog to interact with the user through a graphical interface, making it easier to confirm actions and show progress.

### Features:

- Removes Disabled Snap Revisions: Clean up old versions of snaps that are no longer in use.
- Cleanup Snap Data: Optionally remove data for snaps that have been uninstalled.
- Graphical Interface: Uses KDialog for progress bars, message dialogs, and password prompts.
- Customizable: Easily run the script system-wide or locally for a single user.

### Installation:

You can install the script either system-wide or locally depending on your needs.
System-Wide Installation (requires sudo):

To install the script for all users on the system:

sudo make install

Local Installation (user-specific):

To install the script only for the current user:

make install

The script will be installed to ~/.local/bin.
Uninstall:

To remove the script, you can use:

make uninstall

This will remove the script from the installed location (/usr/local/bin or ~/.local/bin).
Check Help:

To see the available options and how to use the script, run:

make help

Usage:

Once the script is installed, you can run it as follows:

snap_cleanup.sh

Options:

    -h or --help: Show a help message with usage instructions.
    reset: Clear the script's configuration files.

Example:

To run the script and clean up old snaps and data:

    First, run the script to list all disabled snaps:

    snap_cleanup.sh

    The script will display a confirmation message for removing disabled snaps.

    After confirming, you'll be prompted to enter your password (via KDialog).

    The script will then proceed to clean up the disabled snaps and any associated data.

Requirements:

    KDialog: The script relies on KDialog to provide graphical dialogs for user interaction (password prompts, progress bars, etc.).
    sudo: To remove snaps or perform system-wide cleanups, you will need sudo privileges.

Ensure that ~/.local/bin is in your PATH:

If you're installing the script locally (without sudo), make sure ~/.local/bin is included in your shell's PATH variable. If it's not, you can add the following line to your ~/.bashrc or ~/.zshrc:

export PATH="$HOME/.local/bin:$PATH"

Then, reload the configuration:

source ~/.bashrc  # or source ~/.zshrc
