FROM thomasloven/novnc-ubuntu

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y blender

CMD ["blender"]
