#!/bin/bash
cat << GLRUNNER > /etc/systemd/system/gitlab-runner.service
${unitfile}
GLRUNNER

mkdir /etc/gitlab-runner/
chown root:core /etc/gitlab-runner/
chmod g+s /etc/gitlab-runner/
cat << EOF > /etc/gitlab-runner/config.sh
${configscript}
EOF
chmod 755 /etc/gitlab-runner/config.sh

systemctl daemon-reload
systemctl enable gitlab-runner.service
systemctl start gitlab-runner.service
