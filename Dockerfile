FROM arm64v8/debian:bullseye
RUN apt update

# DEPS
RUN apt install -y vim python gcc python2 g++ make build-essential git git-lfs libffi-dev libssl-dev libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 libx11-xcb1 libgdk-pixbuf-2.0-0 libgtk-3-0 libdrm2 libgbm1 ruby ruby-dev curl wget clang llvm lld clang-tools generate-ninja ninja-build pkg-config tcl
RUN gem install fpm
ENV USE_SYSTEM_FPM=true
RUN mkdir -p /usr/include/aarch64-linux-gnu/
# pulled from https://raw.githubusercontent.com/node-ffi-napi/node-ffi-napi/master/deps/libffi/config/linux/arm64/fficonfig.h because its not in debian
COPY fficonfig.h /usr/include/aarch64-linux-gnu/ 
COPY rustup-init /rustup-init
RUN chmod +x /rustup-init
RUN /rustup-init -y

# Buildscripts
COPY signal-buildscript.sh /
RUN chmod +x /signal-buildscript.sh

# Clone signal
RUN git clone https://github.com/signalapp/Signal-Desktop
RUN git clone https://github.com/scottnonnenberg-signal/node-sqlcipher -b updates /sqlcipher
COPY sqlcipher.patch /
# Copy manually patched version of sqlcipher (drops static linking). See sqlcipher.patch.
#COPY /home/user/src/node-sqlcipher /sqlcipher
RUN git clone https://github.com/signalapp/libsignal-client.git
RUN git clone https://github.com/signalapp/libsignal-client-node.git
RUN git clone https://github.com/signalapp/better-sqlite3.git
COPY better-sqlite3.patch /
#RUN git clone https://github.com/signalapp/libsignal-client-node.git
#RUN git clone https://github.com/lsfxz/ringrtc
#RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
#ENV PATH=/depot_tools:$PATH

RUN git clone https://github.com/signalapp/zkgroup.git
RUN git clone https://github.com/signalapp/signal-zkgroup-node.git
COPY zkgroup.patch /

# The same as above will have to happen for ringrtc once it is building

# NODE
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN nvm install 14.16.0
RUN nvm use 14.16.0
RUN npm install --global yarn

#
