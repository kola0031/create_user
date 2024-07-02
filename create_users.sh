#!/bin/bash

# Define the full path to commands
USERADD_CMD="/usr/sbin/useradd"
GROUPADD_CMD="/usr/sbin/groupadd"
USERMOD_CMD="/usr/sbin/usermod"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <user-groups-file>"
    exit 1
fi

USER_FILE="$1"

# Ensure secure directory exists
mkdir -p /var/secure
chmod 700 /var/secure

# Initialize log file
echo "User Management Script Execution Log" > $LOG_FILE
echo "-----------------------------------" >> $LOG_FILE

# Function to generate a random password
generate_password() {
    < /dev/urandom tr -dc A-Za-z0-9 | head -c12
}

# Read the user file line by line
while IFS=';' read -r username groups; do
    # Remove whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists, skipping..." | tee -a $LOG_FILE
        continue
    fi

    # Create personal group for the user
    $GROUPADD_CMD "$username"
    if [ $? -ne 0 ]; then
        echo "Failed to create group $username" | tee -a $LOG_FILE
        continue
    fi
    echo "Created personal group $username" | tee -a $LOG_FILE

    # Create user with the personal group
    $USERADD_CMD -m -s /bin/bash -g "$username" "$username"
    if [ $? -eq 0 ]; then
        echo "Created user $username with personal group $username" | tee -a $LOG_FILE
    else
        echo "Failed to create user $username" | tee -a $LOG_FILE
        continue
    fi

    # Set home directory permissions
    chmod 700 /home/$username
    chown $username:$username /home/$username

    # Assign additional groups
    if [ ! -z "$groups" ]; then
        IFS=',' read -ra group_list <<< "$groups"
        for group in "${group_list[@]}"; do
            # Check if the group exists, if not, create it
            if ! getent group "$group" &>/dev/null; then
                $GROUPADD_CMD "$group"
                echo "Created group $group" | tee -a $LOG_FILE
            fi
            # Add the user to the group
            $USERMOD_CMD -aG "$group" "$username"
            echo "Added user $username to group $group" | tee -a $LOG_FILE
        done
    fi

    # Generate random password
    password=$(generate_password)
    echo "$username:$password" | chpasswd

    # Log the password to secure file
    echo "$username,$password" >> $PASSWORD_FILE
    chmod 600 $PASSWORD_FILE
    chown root:root $PASSWORD_FILE

    echo "Set password for user $username" | tee -a $LOG_FILE

done < "$USER_FILE"

echo "User management script completed successfully." | tee -a $LOG_FILE
