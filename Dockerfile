FROM gentoo/stage3 AS deps

RUN mkdir /scripts

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

COPY ./scripts/write_flags.sh /scripts/write_flags.sh

RUN emerge-webrsync

RUN /scripts/write_flags.sh
COPY ./package.use/gns3 /etc/portage/package.use/gns3
COPY ./profile/package.provided /etc/portage/profile/package.provided

RUN mkdir -p /run/lock

FROM deps AS build

RUN emerge -v --buildpkg \
	dev-build/cmake \
	app-emulation/qemu \
	app-emulation/libvirt \
	app-containers/docker \
	net-libs/libpcap

FROM scratch AS export
COPY --from=build /var/cache/binpkgs /binpkgs
