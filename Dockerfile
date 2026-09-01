FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# The QEMU set matches anyvm's own documented Linux dependencies, so every
# architecture the guests are published for can actually run in here:
# s390x (ubuntu, openeuler, rocky, almalinux), sparc64 (openbsd, netbsd)
# and the misc targets incl. loongarch64 (openeuler) used to be missing,
# which made those --arch values fail with "qemu-system-... not found"
# rather than anything diagnosable.
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
    qemu-system-ppc \
    qemu-system-s390x \
    qemu-system-sparc \
    qemu-system-misc \
    u-boot-qemu  \
    openssh-client \
    nfs-kernel-server \
    openssh-server dropbear

ENV ANYVM_VER=0.6.9

WORKDIR /anyvm.org
ENV WORKDIR=/anyvm.org

# Fetch the RELEASE ASSET, not raw.githubusercontent.com. Everything
# consumed across repository boundaries in this org is addressed as
# releases/download/v<version>/<file>, so the artifact and its version are
# a matched, reproducible pair; the raw path serves whatever the tag points
# at and is the same channel the *-vm actions were moved off. The asset is
# published by anyvm's release-asset.yml on every release and is
# byte-identical to the tagged source (verified by sha256 for v0.6.5).
ADD https://github.com/anyvm-org/anyvm/releases/download/v${ANYVM_VER}/anyvm.py ${WORKDIR}/anyvm.py


ADD entrypoint.sh ${WORKDIR}/entrypoint.sh
RUN chmod +x ${WORKDIR}/entrypoint.sh ${WORKDIR}/anyvm.py && mkdir -p /data

VOLUME [ "/data" ]

# Default SSH port mapping for anyvm VMs
EXPOSE 10022

# Default VNC port mapping for anyvm VMs
EXPOSE 5900

# Default Web VNC port mapping for anyvm VMs
EXPOSE 6080

# qemu monitor port
EXPOSE 7000


ENTRYPOINT ["/anyvm.org/entrypoint.sh"]
CMD ["/bin/bash"]

