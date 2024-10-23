FROM alpine AS builder
WORKDIR /
ARG REF

ENV ZIG_VERSION=0.10.1
ENV ZIG_PATH=/zig/${ZIG_VERSION}/files

RUN apk add --no-cache \
        ca-certificates \
        git make wget curl autoconf automake libtool 
RUN apkArch="$(apk --print-arch)"; \
case "$apkArch" in \
    x86_64) zigupURL='https://github.com/marler8997/zigup/releases/download/v2024_05_05/zigup-x86_64-linux.tar.gz' ;;\
    aarch64) zigupURL='https://github.com/marler8997/zigup/releases/download/v2024_05_05/zigup-aarch64-linux.tar.gz' ;;\
    armv7) zigupURL='https://github.com/marler8997/zigup/releases/download/v2024_05_05/zigup-arm-linux.tar.gz' ;;\
    ppc64le) zigupURL='https://github.com/marler8997/zigup/releases/download/v2024_05_05/zigup-powerpc64le-linux.tar.gz' ;;\
    riscv64) zigupURL='https://github.com/marler8997/zigup/releases/download/v2024_05_05/zigup-riscv64-linux.tar.gz' ;; \
    *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
esac; \
wget -q "$zigupURL" && \
tar -xzf "$(basename $zigupURL)" -C /usr/bin && \
chmod +x /usr/bin/zigup && \
zigup --install-dir /zig ${ZIG_VERSION} \
&& chmod -R a+w ${ZIG_PATH} \
&& rm $PWD/*.tar.gz 
# /usr/bin/zigup -h; 
RUN   git clone  https://github.com/YahuiWong/chinadns-ng.git
RUN  if [[ -z "${REF}" ]]; then \
        echo "No specific commit provided, use the latest one." \
        exit 1 \
    ;else \
        echo "Use commit ${REF}" &&\
        cd chinadns-ng &&\
        git checkout ${REF} &&\
        apkArch="$(apk --print-arch)"; \
        Build_Args="";\
        case "$apkArch" in \
            x86_64) Build_Args='-Dtarget=native-native-musl -Dcpu=x86_64' ;; \
            aarch64) Build_Args='-Dtarget=aarch64-linux-musl ' ;; \
            armv7) Build_Args='-Dtarget=arm-linux-musleabi ';; \
            ppc64le) Build_Args='';; \
            riscv64)  Build_Args='';; \
            *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
        esac; \
        echo $Build_Args &&\
        zig build ${Build_Args}  &&\
        # ls zig-out/bin -lash \
        mv zig-out/bin/chinadns-ng@* zig-out/bin/chinadns-ng \
    ;fi 
FROM alpine
WORKDIR /
RUN apk add --no-cache tzdata ca-certificates
COPY --from=builder /chinadns-ng/zig-out/bin /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/chinadns-ng", "--config"]
CMD ["/etc/chinadns-ng/config.json"]