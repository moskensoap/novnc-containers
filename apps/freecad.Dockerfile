FROM thomasloven/novnc-base

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y software-properties-common \
  && sudo add-apt-repository -y ppa:freecad-maintainers/freecad-daily \
  && sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y freecad-daily

