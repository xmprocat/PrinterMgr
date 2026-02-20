# PrinterMgr
printer manager for openwrt

# Useage

1. Download the OpenWRT SDK
2. add to feeds.conf


```

# Add the package feed
echo "src-git PrinterMgr https://github.com/xmprocat/PrinterMgr.git;main" >> feeds.conf.default

```

3. update feeds&install feeds
```
./scripts/feeds update -a
./scripts/feeds install -a

```
