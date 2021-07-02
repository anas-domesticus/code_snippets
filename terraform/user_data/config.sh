#!/bin/sh

# The below is slightly hacky, but i don't see a better way of handling it as the merging doesn't work
sed -i 's/concurrent = 1/concurrent = ${concurrency}/g' /etc/gitlab-runner/config.toml
sed -i 's#"/cache"#"/cache", "/var/run/docker.sock:/var/run/docker.sock"#g' /etc/gitlab-runner/config.toml