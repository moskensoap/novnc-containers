docker build $@ -t thomasloven/novnc-ubuntu -f ubuntu.Dockerfile .
docker build $@ -t thomasloven/novnc-debian -f debian.Dockerfile .
docker build $@ -t thomasloven/novnc-alpine -f alpine.Dockerfile .
