FROM rust:1.37.0-slim-buster 
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git pkg-config cmake libssl-dev \
      unzip wget sudo bash-completion && \
    wget -O /tmp/a.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protoc-3.8.0-linux-x86_64.zip && \
    (cd /usr/local/ && unzip /tmp/a.zip && rm /tmp/a.zip) && \
    apt-get clean && apt-get remove -y unzip wget && apt-get autoremove -y && rm -fr /var/lib/apt/lists/* && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo,root -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user

USER user
WORKDIR /home/user
RUN cargo install --force --git https://github.com/mozilla/sccache && \
    rustup update && \
    rustup component add rustfmt && \
    rustup component add clippy && \
    git clone https://github.com/libra/libra.git && \
    cd libra && \
    RUSTC_WRAPPER=`which sccache` cargo build && \
    cd .. && \
    rm -fr libra/

USER root

RUN sed s#user:x.*#user:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g /etc/passwd > /.passwd.template && \
    sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g /etc/group > /.group.template && \
    mkdir /projects && \
    for f in /home/user /etc/passwd /etc/group $CARGO_HOME /projects; do \
      chgrp -R 0 $f && \
      chmod -R g+rwX $f; \
    done

WORKDIR /projects
VOLUME /projects

ENV RUSTC_WRAPPER $CARGO_HOME/bin/sccache

COPY [ "entrypoint.sh", "/entrypoint.sh" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "tail", "-f", "/dev/null" ]
