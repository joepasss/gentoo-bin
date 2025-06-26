## joepasss/gentoo-bin

---


### Usage


* add `getbinpkg` option and `PORTAGE_BINHOST` value

``` bash
# /etc/portage/make.conf

# ... some configurations ...

FEATURES="getbinpkg"

# amd64 binary host
PORTAGE_BINHOST="https://joepasss.github.io/gentoo-bin/packages/amd64"
# arm64 binary host
PORTAGE_BINHOST="https://joepasss.github.io/gentoo-bin/packages/aarch64"

# ... more configurations ...
```

* `emerge --getbinpkg <my_package>` or `emerge -g <my_package>`

[gentoo wiki, binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)


### Package List

[Packages](https://github.com/joepasss/gentoo-bin/blob/gh-pages/packages/binpkgs/Packages)
