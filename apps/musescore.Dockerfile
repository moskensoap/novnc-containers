FROM thomasloven/novnc-ubuntu

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y software-properties-common \
  && sudo add-apt-repository -y ppa:mscore-ubuntu/mscore3-stable \
  && sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y musescore3

CMD ["musescore3"]
