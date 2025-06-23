FROM joepasss/crossdev AS deps

ENV CROSSROOT=/usr/aarch64-unknown-linux-gnu

RUN test -d "$CROSSROOT"

RUN mkdir /scripts

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

COPY ./scripts/write_flags.sh /scripts/write_flags.sh

RUN /scripts/write_flags.sh /etc/portage/make.conf
RUN /scripts/write_flags.sh "$CROSSROOT/etc/portage/make.conf"

RUN [ -d /etc/portage/package.use ] || mkdir -pv /etc/portage/package.use
RUN [ -d "$CROSSROOT/etc/portage/package.use" ] || mkdir -pv "$CROSSROOT"/etc/portage/package.use

COPY ./package.use/gns3 /etc/portage/package.use/gns3
COPY ./package.use/gns3 "$CROSSROOT/etc/portage/package.use/gns3"
COPY ./package.use/arm64_gns "$CROSSROOT/etc/portage/package.use/arm64_gns"
COPY ./profile/package.provided /etc/portage/profile/package.provided
COPY ./profile/package.provided "$CROSSROOT/etc/portage/profile/package.provided"

RUN mkdir -p /run/lock

RUN emerge \
	-gv --onlydeps --oneshot \
	dev-lang/go-bootstrap

RUN emerge-aarch64-unknown-linux-gnu \
	-gv --onlydeps --oneshot \
	dev-lang/go-bootstrap

FROM deps AS build

RUN emerge \
	-v --buildpkg \
	dev-build/cmake \
	app-emulation/qemu \
	app-emulation/libvirt \
	app-containers/docker \
	net-libs/libpcap

RUN emerge-aarch64-unknown-linux-gnu \
	-v --buildpkg \
	dev-build/cmake \
	app-emulation/qemu \
	app-emulation/libvirt \
	app-containers/docker \
	net-libs/libpcap

FROM scratch AS export
COPY --from=build /var/cache/binpkgs /binpkgs
