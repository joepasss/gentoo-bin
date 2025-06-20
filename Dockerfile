FROM gentoo/stage3 AS deps

RUN mkdir /scripts

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

COPY ./scripts/write_flags.sh /scripts/write_flags.sh

RUN emerge-webrsync

RUN /scripts/write_flags.sh
RUN mkdir -p /run/lock

FROM deps AS cmake_build

RUN emerge -v --buildpkg \
	dev-build/cmake

FROM cmake_build AS qemu_build

RUN emerge -v --buildpkg \
	app-emulation/qemu

FROM qemu_build AS libvirt_build

RUN emerge -v --buildpkg \
	app-emulation/libvirt

FROM libvirt_build AS docker_build

RUN emerge -v --buildpkg \
	app-containers/docker \
	net-libs/libpcap

FROM scratch AS export
COPY --from=cmake_build /var/cache/binpkgs /binpkgs
