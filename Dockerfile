FROM ubuntu

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends\
        bash \
        sudo \
        git \
        procps

RUN mkdir -p /opt/noVNC

RUN adduser --home /home/novnc --shell /bin/bash --system --disabled-password novnc \
    && echo "novnc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# X11 and xfce
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends\
        xvfb xauth dbus-x11 xfce4 xfce4-terminal \
        x11-xserver-utils

# VNC
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends\
        python3 python3-pip \
        tigervnc-standalone-server tigervnc-common \
        openssl \
    && pip3 install numpy

# NoVNC
RUN git clone --single-branch https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone --single-branch https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify \
    && ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

RUN openssl req -batch -new -x509 -days 365 -nodes -out self.pem -keyout /opt/noVNC/utils/websockify/self.pem


# Audio
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends\
        pulseaudio \
        pavucontrol \
        ucspi-tcp \
        gstreamer1.0-plugins-good \
        gstreamer1.0-pulseaudio \
        gstreamer1.0-tools

COPY pulse/ /etc/pulse
COPY novnc /opt/noVNC/
RUN sed -i "/import RFB/a \
        import '../webaudio.js'" \
    /opt/noVNC/app/ui.js

# Extra applications
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends\
        firefox neovim

COPY entrypoint.sh /opt/noVNC/entrypoint.sh

ENTRYPOINT ["/opt/noVNC/entrypoint.sh"]
EXPOSE 8080

USER novnc
WORKDIR /home/novnc
