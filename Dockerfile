FROM gentoo/stage3 AS deps

RUN mkdir /scripts

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

COPY ./scripts/write_flags.sh /scripts/write_flags.sh

RUN emerge-webrsync

RUN /scripts/write_flags.sh

FROM deps AS cmake_build

RUN mkdir -p /run/lock
RUN emerge -v --buildpkg=y dev-build/cmake

FROM scratch AS export
COPY --from=cmake_build /var/cache/binpkgs /binpkgs

CMD [ "/bin/bash" ]

