FROM joepasss/crossdev AS deps

ENV CROSSROOT=/usr/aarch64-unknown-linux-gnu

RUN test -d "$CROSSROOT"

RUN rm -rf /scripts

RUN mkdir /scripts

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

COPY ./scripts/write_makeopts.sh /scripts/write_makeopts.sh

RUN [ -d /etc/portage/package.use ] || mkdir -pv /etc/portage/package.use
RUN [ -d "$CROSSROOT/etc/portage/package.use" ] || mkdir -pv "$CROSSROOT"/etc/portage/package.use

RUN rm -rv /etc/portage/make.conf
COPY ./portage/make.conf /etc/portage/make.conf

RUN /scripts/write_makeopts.sh /etc/portage/make.conf
RUN /scripts/write_makeopts.sh "$CROSSROOT/etc/portage/make.conf"

COPY ./portage/profile/ /tmp/profile/

COPY ./portage/package.use/gns3 /etc/portage/package.use/gns3
COPY ./portage/package.use/gns3 "$CROSSROOT/etc/portage/package.use/gns3"
COPY ./portage/package.use/arm64_gns "$CROSSROOT/etc/portage/package.use/arm64_gns"

RUN <<-EOF
	set -e

	SOURCE="/tmp/profile/package.provided"
	HOST_TARGET="/etc/portage/profile/package.provided"
	CROSSDEV_TARGET="/usr/aarch64-unknown-linux-gnu/etc/portage/profile/package.provided"

	if [[ -f "$HOST_TARGET" ]]; then
		cat "$SOURCE" >> "$HOST_TARGET"
	else
		cp "$SOURCE" "$HOST_TARGET"
	fi

	if [[ -f "$CROSSDEV_TARGET" ]]; then
		cat "$SOURCE" >> "$CROSSDEV_TARGET"
	else
		cp "$SOURCE" "$CROSSDEV_TARGET"
	fi
EOF

RUN rm -rf /tmp/profile

RUN mkdir -p /run/lock
RUN getuto

FROM deps AS build

RUN emerge \
	-v --buildpkg \
	acct-user/tss \
	acct-group/tss \
	app-emulation/qemu \
	app-emulation/libvirt \
	app-containers/docker \
	net-libs/libpcap

RUN emerge-aarch64-unknown-linux-gnu \
	-v --buildpkg \
	app-emulation/qemu \
	app-containers/docker \
	net-libs/libpcap

FROM scratch AS export
COPY --from=build /var/cache/binpkgs /packages/amd64
COPY --from=build /usr/aarch64-unknown-linux-gnu/var/cache/binpkgs /packages/aarch64
