# create_user #Technical Article

Streamlining User and Group Management with a Bash Script

Managing users and groups is a critical task for any SysOps engineer, especially when onboarding new employees. Manual management can be error-prone and time-consuming. Automating this process ensures consistency, security, and efficiency. In this article, we will explore a Bash script that automates the creation of users and groups, sets up home directories with proper permissions, generates random passwords, and logs all actions for audit purposes.

Why Automate User and Group Management?

1. Consistency: Automating the process ensures that all users are created with the same configurations and security settings.
2. Efficiency: Reduces the time and effort required to manually create users and assign groups, especially when onboarding multiple employees at once.
3. Security: Generates secure random passwords and ensures home directories have appropriate permissions.
4. Auditability: Logs all actions performed by the script, providing an audit trail for compliance and troubleshooting.

Script Breakdown

Log and Password File Setup

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

These variables define the paths for the log file and the secure password file. The log file records all actions performed by the script, and the password file securely stores the generated passwords.

Input File Check

if [ -z "$1" ]; then
    echo "Usage: $0 <user-groups-file>"
    exit 1
fi

This block checks if the input file is provided as an argument. If not, it prints a usage message and exits the script.

Secure Directory Setup

mkdir -p /var/secure
chmod 700 /var/secure

Ensures the secure directory exists and sets appropriate permissions, allowing only the owner to access it.

Logging Initialization

echo "User Management Script Execution Log" > $LOG_FILE
echo "-----------------------------------" >> $LOG_FILE

Initializes the log file with a header.

Random Password Generation

generate_password() {
    < /dev/urandom tr -dc A-Za-z0-9 | head -c12
}

Defines a function to generate a random 12-character password.

Reading the User File

while IFS=';' read -r username groups; do
    ...
done < "$USER_FILE"

Reads each line of the input file, extracting usernames and groups.

User and Group Creation

$GROUPADD_CMD "$username"
$USERADD_CMD -m -s /bin/bash -g "$username" "$username"

Creates a personal group for the user and then creates the user with that group as their primary group.

Setting Permissions

chmod 700 /home/$username
chown $username:$username /home/$username

Sets appropriate permissions for the user's home directory.

Assigning Additional Groups

if [ ! -z "$groups" ]; then
    IFS=',' read -ra group_list <<< "$groups"
    for group in "${group_list[@]}"; do
        ...
    done
fi

Assigns the user to additional groups specified in the input file.

Password Management

password=$(generate_password)
echo "$username:$password" | chpasswd
echo "$username,$password" >> $PASSWORD_FILE

Generates a password, sets it for the user, and logs it to the secure file.

Conclusion

This script provides an efficient and secure way to manage user and group creation, ensuring that new employees are onboarded quickly and consistently. By automating these tasks, we reduce the risk of errors and improve overall system security.

For more information about opportunities in the HNG Internship program, visit HNG Internship (https://hng.tech/internship) or learn about hiring top talent at HNG Hire (https://hng.tech/hire).

Implementing this script in your environment can streamline your user management processes, ensuring a secure and efficient workflow.



