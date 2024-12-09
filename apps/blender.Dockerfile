FROM thomasloven/novnc-base

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y blender

CMD ["blender"]
