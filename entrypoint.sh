#! /bin/bash

shopt -s nullglob

kill_pid() {
  if [ -f $1 ]; then
    cat $1 | xargs kill > /dev/null 2>&1
    rm -f $1
  fi
}

# Perform cleanup and remove X1 lock files if the container was restarted
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
kill_pid ~/.vnc-pid
kill_pid ~/.pa-pid
kill_pid ~/.tcp-pid
kill_pid ~/.ws-pid

# Clone and install dotfiles if DOTFILES_REPO is defined
if [ -n "$DOTFILES_REPO" ]; then
  if [ ! -d ~/dotfiles ]; then
    git clone $DOTFILES_REPO ~/dotfiles
    if [ -f ~/dotfiles/install.sh ]; then
      /bin/bash ~/dotfiles/install.sh
    fi
  fi
fi

# Launch VNC server - view :1 defaults to port 5901
vncserver :1 -SecurityTypes None -localhost no --I-KNOW-THIS-IS-INSECURE &
echo "$!" > ~/.vnc-pid

# Launch pulseaudio server
# /etc/pulse/client.conf and /etc/pulse/default.pa are setup to make a default
# audio sink which outputs to a socket at /tmp/pulseaudio.socket
DISPLAY=:0.0 pulseaudio --disallow-module-loading --disallow-exit --exit-idle-time=-1&
echo "$!" > ~/.pa-pid

# Use gstreamer to stream the pulseaudio source /tmp/pulseaudio.socket to stdout (fd=1)
# the tcpserver from ucspi-tcp pipes this to tcp port 6901
tcpserver localhost 6901 gst-launch-1.0 -q pulsesrc server=/tmp/pulseaudio.socket ! audio/x-raw, channels=2, rate=12000 ! cutter ! opusenc ! webmmux ! fdsink fd=1 &
echo "$!" > ~/.tcp-pid

# Websockify does three things:
# - publishes /opt/noVNC to http port 8080
# - proxies vnc port 5901 to 8080/websockify?token=vnc
# - proxies pulseaudio port 6901 to 8080/websockify?token=pulse
# The latter two are defined through the tokenfile
/opt/noVNC/utils/websockify/websockify.py --web /opt/noVNC 8080 --token-plugin=TokenFile --token-source=/opt/noVNC/tokenfile &
echo "$!" > ~/.ws-pid

if [ -n "$@" ]; then
  DISPLAY=:1.0 exec "$@" &
fi

wait

