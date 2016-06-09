#!/usr/bin/bash
# Simple bash script to parse users from /etc/passwd
# into usable format for CFengine3

#Variables
altshell="/usr/lbexec/sftp-server"
file="/etc/passwd"

while IFS=: read -r f1 f2 f3 f4 f5 f6 f7
do
          printf '"sftp_users[%s][password]"  string => "x"; \n' "$f1"
          printf '"users[%s][uid]"            string => "%s"; \n' "$f1" "$f3"
          printf '"users[%s][uid]"            string => "%s"; \n' "$f1" "$f4"
          printf '"users[%s][gecos]"          string => "%s"; \n' "$f1" "$f5"
          printf '"users[%s][group]"          string => "%s"; \n' "$f1" "$f1"
          printf '"users[%s][directory]"      string => "%s"; \n' "$f1" "$f6"
          printf '"users[%s][uid]"            string => "%s"; \n' "$f1" "$f1"
          printf '"users[%s][uid]"            string => "%s"; \n \n' "$f1" "$altshell"
done <"$file"
