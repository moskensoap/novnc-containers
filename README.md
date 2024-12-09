# NOVNC-BASE

A desktop environment with sound in docker

Can be used as a base file for application specific containers.


E.g:
```dockerfile
FROM thomasloven/novnc-base

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y blender

CMD ["blender"]
```

### Bonus functionality - dotfiles installation.
If the environment variable `DOTFILES_REPO` is set, the container will `git
clone` that into `~/dotfiles` and then run `~/dotfiles/install.sh` if it
exists.


