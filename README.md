# bootstrap
Bootstrap my ideal Linux shell environment

This is the line to execute in a Debian/Ubuntu environment:
```bash
$ sudo apt-get install -y vim git tree tmux bash-completion net-tools iproute2 dnsutils neofetch zsh exa batcat; \
    (test -d /tmp/bootstrap || git clone --depth 1 https://github.com/dyle71/bootstrap.git /tmp/bootstrap); \
    (cd /tmp/bootstrap && ./bootstrap.apt.sh && cd .. && rm -rf /tmp/bootstrap)
```

This is the line to execute in an Arch environment:
```bash
$ sudo pacman -S vim git tree tmux bash-completion net-tools iproute2 dnsutils neofetch zsh exa batcat; \
    (test -d /tmp/bootstrap || git clone --depth 1 https://github.com/dyle71/bootstrap.git /tmp/bootstrap); \
    (cd /tmp/bootstrap && ./bootstrap.pacman.sh && cd .. && rm -rf /tmp/bootstrap)
```
