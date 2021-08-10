#!/bin/bash

rm -rf /root/shell && \
mkdir /root/shell && \
cd /root/shell

git clone https://github.com/kkAtGithub/shell.git ./ || \
(apt install git -y && git clone https://github.com/kkAtGithub/shell.git ./)
chmod 700 -R ./

exit 0
