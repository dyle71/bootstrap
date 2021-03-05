# bootstrap
Bootstrap my ideal Linux shell environment


This is the line to execute in a Debian/Ubuntu environment:
```bash
$ apt-get install -y vim git tree tmux bash-completion net-tools iproute2 dnsutils neofetch; \
    (test -d /tmp/bootstrap || git clone --depth 1 https://github.com/dyle71/bootstrap.git /tmp/bootstrap); \
    (cd /tmp/bootstrap && ./bootstrap.sh && cd .. && rm -rf /tmp/bootstrap)
```

