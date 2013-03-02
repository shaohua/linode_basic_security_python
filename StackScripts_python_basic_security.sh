#!/bin/bash
#based on http://www.linode.com/stackscripts/view/?StackScriptID=131

# <UDF name="user_name" label="Unprivileged user account name" example="This is the account that you will be using to log in." />
# <UDF name="user_password" label="Unprivileged user password" />
# <UDF name="user_sshkey" label="Public Key for user" default="" example="Recommended method of authentication. It is more secure than password log in." />
# <UDF name="sshd_passwordauth" label="Use SSH password authentication" oneof="Yes,No" default="No" example="Turn off password authentication if you have added a Public Key." />
# <UDF name="sshd_permitrootlogin" label="Permit SSH root login" oneof="No,Yes" default="No" example="Root account should not be exposed." />

# <UDF name="user_shell" label="Shell" oneof="/bin/zsh,/bin/bash" default="/bin/bash" />

# <UDF name="sys_hostname" label="System hostname" default="myvps" example="Name of your server, i.e. linode1." />


set -e
set -u
#set -x

USER_GROUPS=sudo

exec &> /root/stackscript.log

source <ssinclude StackScriptID="1"> # StackScript Bash Library
system_update

source <ssinclude StackScriptID="124"> # lib-system

# Configure system
source <ssinclude StackScriptID="123"> # lib-system-ubuntu
system_update_hostname "$SYS_HOSTNAME"

# Create user account
system_add_user "$USER_NAME" "$USER_PASSWORD" "$USER_GROUPS" "$USER_SHELL"
if [ "$USER_SSHKEY" ]; then
    system_user_add_ssh_key "$USER_NAME" "$USER_SSHKEY"
fi

# Configure sshd
system_sshd_permitrootlogin "$SSHD_PERMITROOTLOGIN"
system_sshd_passwordauthentication "$SSHD_PASSWORDAUTH"
touch /tmp/restart-ssh

# Lock user account if not used for login
if [ "SSHD_PERMITROOTLOGIN" == "No" ]; then
    system_lock_user "root"
    echo "Locked root account" # SS124
fi

restart_services
restart_initd_services

#added by sz
# Installs the REAL vim, wget, less, and enables color root prompt and the "ll" list long alias
goodstuff