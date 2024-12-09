FROM thomasloven/novnc-base

ARG APPIMAGE=PrusaSlicer-2.8.1+linux-x64-older-distros-GTK3-202409181354.AppImage
ARG URL=https://github.com/prusa3d/PrusaSlicer/releases/download/version_2.8.1/${APPIMAGE}

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y \
    libgtk-3-dev libglu1-mesa libwebkit2gtk-4.0-37 \
    locales curl \
  && sudo locale-gen en \
  && curl -sSL ${URL} > ${APPIMAGE} \
  && chmod +x ${APPIMAGE} \
  && ./${APPIMAGE} --appimage-extract

RUN mkdir -p ~/Desktop \
&& echo '[Desktop Entry]\n\
Version=1.0\n\
Type=Application\n\
Name=PrusaSlicer\n\
Comment=\n\
Exec=/home/novnc/squashfs-root/AppRun\n\
Icon=/home/novnc/squashfs-root/PrusaSlicer.png\n\
PATH=\n\
Terminal=false\n\
StartupNotify=false'> ~/Desktop/PrusaSlicer.desktop \
&& chmod +x ~/Desktop/PrusaSlicer.desktop
