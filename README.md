# NOVNC-BASE

A desktop environment with sound in docker.

Can be used as a base file for application specific containers.

- `thomasloven/novnc-ubuntu`
- `thomasloven/novnc-debian`
- `thomasloven/novnc-alpine`

To just get a desktop environment at `http://localhost:8080`:

```bash
docker run --rm -p 8080:8080 thomasloven/novnc-ubuntu
```

Or used as a base for specific applications:

```dockerfile
FROM thomasloven/novnc-ubuntu

RUN sudo apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  sudo apt-get install -y blender

CMD ["blender"]
```

See more examples in `apps/`.


The container will run as user `$USERNAME` (default `novnc`) with uid `${UUID}` (default `1000`) and group id `${GUID}` (default `1000`).
The user has sudo privileges with no password(!).

### Bonus functionality - dotfiles installation.
If the environment variable `DOTFILES_REPO` is set, the container will `git
clone` that into `~/dotfiles` and then run `~/dotfiles/install.sh` if it
exists.


