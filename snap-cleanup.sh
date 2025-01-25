#!/bin/bash
# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS

# Function to display a message dialog
show_message_dialog() {
    local message=$1
    local type=${2:-msgbox}
    local title=${3:-Snap Cleanup}
    local dontagain=${4}
    kdialog ${dontagain} --title "$title" --"$type" "$message" 2>/dev/null
    local response=$?
    echo $response
    if [ $response -eq 2 ]; then
        exit 0
    fi
    return $response
}

# Function to display a password dialog and store the entered password
get_password() {
    show_message_dialog "Removing snaps will need administrative permissions.\nFor administrative permissions, sudo password is needed" "password" "Enter Password"
}

# Function to display a progress dialog
show_progress_dialog() {
    dbusref=$1
    snap_name=$2
    revision=$3
    snap_number=$4
    qdbus $dbusref Set "" value "$snap_number"
    qdbus $dbusref setLabelText "Removing snap $snap_name - $revision"
}

remove_snaps() {
    password=$1
    qdbusref=$2
    qdbus $qdbusref setAutoClose true
    qdbus $qdbusref showCancelButton false
    snap_number=0
    # Loop through each snap and remove old revisions
    echo "$snap_list" |
    while read -r snapname revision; do
        snap_number=$((snap_number + 1))
        show_progress_dialog "$qdbusref" "$snapname" "$revision" "$snap_number"
        echo "$password" | sudo -S snap remove "$snapname" --revision="$revision" >/dev/null 2>&1
    done
}

cleanup_folders(){
    local folders=$(ls -d /home/"$USER"/snap/* 2>/dev/null)
    for folder in $folders; do
        local snap_name=$(basename "$folder")
        if ! echo "$snap_installed_list" | grep -q "^$snap_name$"; then
            if ! show_message_dialog "Found a folder named $snap_name in ~/snap/ but "$snap_name" is not installed anymore.\nDo you want to remove the data?" "warningyesno" "Remove $folder" "--dontagain snap-cleanup:noaskwhencleardata"; then
                show_message_dialog "Keeping data of snap $snap_name" "msgbox" "Snap Cleanup" "--dontagain snap-cleanup:noaskwhencleardata"
                continue
            else
                local qdbusref=$(kdialog --title "Snap Cleanup" --progressbar "Removing folder $snap_name" 0)
                qdbus $qdbusref setAutoClose true
                qdbus $qdbusref showCancelButton false
                sleep 2 && rm -rf "$folder"
                qdbus $qdbusref close
                show_message_dialog "Successfully removed $folder" "msgbox" "Remove $folder" "--dontagain snap-cleanup:noaskwhencleardata"
            fi
        fi
    done
}

check_password(){
    local password=$1
    local user=$(echo $password | sudo -S whoami 2>/dev/null)
    if [[ "$user" == "root" ]]; then
        return 0
    else
        return 1
    fi
}

show_help() {
    cat <<EOF
Usage: $0 [options]

This script removes old revisions of snaps and their associated data.

Options:
  -h, --help          Show this help message and exit
  reset               Clear the config files and exit

Before running, ensure all snaps are closed.

Steps:
  1. The script will first list all disabled snaps.
  2. It will ask for confirmation to remove them.
  3. Then, it will prompt for your sudo password to proceed with the removal.
  4. Afterward, it will ask whether to clear the data of uninstalled snaps.

Note: This script requires kdialog and dbus to show progress dialogs.

EOF
    exit 0
}

main(){
    # Confirm removal with the user
    if ! show_message_dialog "This script will remove $snap_count disabled snaps.\nAre you sure, you want to remove them?" "warningyesno"; then
        exit 0
    fi
    # Prompt for sudo password
    local password=$(get_password)
    if [ -z $password ]; then
        show_message_dialog "Password is needed for sudo permissions.\nExiting!" "error" "Password Error"
        exit 0
    fi
    if ! check_password $password; then
        show_message_dialog "Wrong password entered!" "error" "Password Error"
        exit 0
    fi
    local qdbusref
    qdbusref=$(kdialog --title "Snap Cleanup" --progressbar "Removing disabled snaps" "${snap_count}" 2>/dev/null)
    remove_snaps "$password" "$qdbusref"
    qdbus $qdbusref close
    show_completion_message "$snap_count"
}

show_completion_message(){
    # Show completion message
    if [ "${snap_count}" -ge 1 ]; then
        show_message_dialog "Removed $snap_count disabled snaps."
    elif [ "${snap_count}" == 1 ]; then
        show_message_dialog "Removed $snap_count disabled snap."
    else
        show_message_dialog "No disabled snaps found."
    fi
}

if [[ -n "$DEBUG" ]]; then
    set -x
fi

# Parse command-line arguments using a case statement
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        --reset)
            echo "Cleared the configs"
            rm -rf $HOME/.config/snap-cleanup
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
    shift
done

# Get list of disabled snaps
snap_list=$(snap list --all | awk '/disabled/{print $1, $3}')
snap_installed_list=$(snap list | awk '{print $1}')
whoami
# Count the number of snaps to remove
snap_count=$(echo "$snap_list" | grep -c .)

if [ "${snap_count}" -eq 0 ]; then
    show_message_dialog "No disabled snaps found." "sorry"
else
    main "$snap_count" "$snap_list" "$password"
fi

if ! show_message_dialog "Clear the data of uninstalled snaps?" "warningyesno"; then
    exit 0
fi
cleanup_folders
show_message_dialog "Done! Cleared all the data!"
