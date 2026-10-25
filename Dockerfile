FROM ubuntu:24.04

ARG HOST_UID=1000
ARG HOST_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/lib/llvm-18/bin:/opt/ps5-payload-sdk/bin:/usr/share/dotnet:${PATH}" \
    PS5_PAYLOAD_SDK=/opt/ps5-payload-sdk \
    LLVM_CONFIG=/usr/lib/llvm-18/bin/llvm-config \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    DOTNET_CLI_WORKLOAD_UPDATE_NOTIFY_DISABLE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      build-essential \
      ca-certificates \
      clang-18 \
      cmake \
      curl \
      lld-18 \
      llvm-18 \
      make \
      meson \
      ninja-build \
      pkg-config \
      python3 \
      python3-pyelftools \
      socat \
      unzip \
      wget \
      xz-utils \
      libssl-dev \
      librsvg2-bin \
      git \
    && ln -sf /usr/lib/llvm-18/bin/llvm-config /usr/local/bin/llvm-config \
    && rm -rf /var/lib/apt/lists/*

# ps5-payload-sdk (prospero-clang, headers, libs)
RUN git clone --depth 1 https://github.com/ps5-payload-dev/sdk.git /tmp/ps5-payload-sdk-src && \
    export LLVM_CONFIG=/usr/lib/llvm-18/bin/llvm-config && \
    export PATH=/usr/lib/llvm-18/bin:${PATH} && \
    make -C /tmp/ps5-payload-sdk-src DESTDIR=/opt/ps5-payload-sdk install && \
    cd /tmp/ps5-payload-sdk-src && \
    ./libcxx.sh && \
    rm -rf /tmp/ps5-payload-sdk-src

# .NET SDK 10 (pkg-builder / LibProsperoPkg)
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet && \
    rm -f /tmp/dotnet-install.sh && \
    ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet

RUN if getent group "${HOST_GID}" >/dev/null; then \
            builder_group="$(getent group "${HOST_GID}" | cut -d: -f1)"; \
        else \
            groupadd --gid "${HOST_GID}" builder; \
            builder_group=builder; \
        fi && \
        existing_user="$(getent passwd "${HOST_UID}" | cut -d: -f1 || true)" && \
        if [ -n "${existing_user}" ] && [ "${existing_user}" != builder ]; then \
            usermod --login builder "${existing_user}" && \
            usermod --home /home/builder --move-home builder; \
        elif ! id builder >/dev/null 2>&1; then \
            useradd --uid "${HOST_UID}" --gid "${HOST_GID}" --create-home --shell /bin/bash builder; \
        fi && \
        usermod --gid "${HOST_GID}" --shell /bin/bash builder && \
        mkdir -p /workspace && \
        chown -R builder:"${builder_group}" /workspace

USER builder
WORKDIR /workspace

# Consume the SDK first-run experience (workload verification, sentinels) at image build time
# so runtime builds never print "An issue was encountered verifying workloads".
RUN mkdir -p /tmp/dotnet-warmup && cd /tmp/dotnet-warmup && \
    printf '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework></PropertyGroup></Project>' > w.csproj && \
    printf 'class W{static void Main(){}}' > W.cs && \
    dotnet build -c Release -v q -nologo && \
    cd / && rm -rf /tmp/dotnet-warmup

CMD ["/bin/bash"]
