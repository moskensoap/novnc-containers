FROM alpine

RUN apk update \
    && apk add \
# Some basic helpers \
        bash \
        sudo \
        git \
        procps \
\
# X11 and XFCE \
    && apk add \
        xvfb xauth dbus-x11 xfce4 xfce4-terminal \
\
# VNC \
    && apk add \
        python3 py3-numpy \
        tigervnc \
        openssl \
\
# NoVNC \
    && mkdir -p /opt/noVNC \
    && git clone --single-branch https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone --single-branch https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify \
    && ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html \
    && openssl req -batch -new -x509 -days 365 -nodes -out self.pem -keyout /opt/noVNC/utils/websockify/self.pem \
# Audio requirements \
    && apk add \
        pulseaudio \
        pavucontrol \
        ucspi-tcp6 \
        gstreamer \
        gstreamer-tools \
        gst-plugins-good \
        xfce4-pulseaudio-plugin

COPY pulse/ /etc/pulse
COPY novnc /opt/noVNC/
RUN sed -i "/import RFB/a \
        import '../webaudio.js'" \
    /opt/noVNC/app/ui.js

# Base applications
RUN apk update \
    && apk add \
        firefox-esr neovim

COPY entrypoint.sh /opt/noVNC/entrypoint.sh

ENTRYPOINT ["/opt/noVNC/entrypoint.sh"]
EXPOSE 8080

RUN adduser --home /home/novnc --shell /bin/bash --system --disabled-password novnc \
    && echo "novnc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add a custom version of vncserver which discards all arguments but the display
RUN mv /usr/bin/vncserver /usr/bin/vncserver-orig \
  && echo -e "#!/bin/bash \n \
  /usr/bin/vncserver-orig \$1" > /usr/bin/vncserver \
  && chmod +x /usr/bin/vncserver

USER novnc
RUN mkdir -p /home/novnc/.vnc/ \
    && echo -e "-Securitytypes=none" > /home/novnc/.vnc/config \
    && touch /home/novnc/.vnc/passwd && chmod 0600 /home/novnc/.vnc/passwd
WORKDIR /home/novnc
