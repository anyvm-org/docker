FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get --no-install-recommends -y install \
    zstd \
    ovmf \
    xz-utils \
    qemu-utils \
    ca-certificates \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-efi-aarch64 \
    rsync qemu-efi-riscv64 \
    qemu-system-riscv64 \
    u-boot-qemu  \
    openssh-client \
    nfs-kernel-server \
    openssh-server dropbear

ENV ANYVM_VER=0.0.4

WORKDIR /anyvm.org
ENV WORKDIR=/anyvm.org

ADD https://raw.githubusercontent.com/anyvm-org/anyvm/refs/tags/v${ANYVM_VER}/anyvm.py ${WORKDIR}/anyvm.py


ADD entrypoint.sh ${WORKDIR}/entrypoint.sh
RUN chmod +x ${WORKDIR}/entrypoint.sh ${WORKDIR}/anyvm.py && mkdir -p /data

VOLUME [ "/data" ]

ENTRYPOINT ["/anyvm.org/entrypoint.sh"]
CMD ["/bin/bash"]

