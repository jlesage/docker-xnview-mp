# Docker container for XnView MP
[![Release](https://img.shields.io/github/release/jlesage/docker-xnview-mp.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-xnview-mp/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/xnview-mp/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/xnview-mp/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/xnview-mp?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/xnview-mp)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/xnview-mp?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/xnview-mp)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-xnview-mp/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-xnview-mp/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-xnview-mp)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a Docker container for [XnView MP](https://www.xnview.com/en/xnview/).

The graphical user interface (GUI) of the application can be accessed through a
modern web browser, requiring no installation or configuration on the client

---

[![XnView MP logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/xnview-mp-icon.png&w=110)](https://www.xnview.com/en/xnview/)[![XnView MP](https://images.placeholders.dev/?width=288&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=XnView%20MP&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://www.xnview.com/en/xnview/)

XnView is a powerful, versatile and free image viewer, photo management, and
image resizer software. XnView is one of the most stable, user-friendly, and
comprehensive photo management tools available today, perfect for both beginners
and professionals. All common picture and graphics formats are supported (JPEG,
TIFF, PNG, GIF, WEBP, PSD, JPEG2000, JPEG-XL*, OpenEXR, camera RAW, HEIF, HEIC,
AVIF, DICOM, PDF, DNG, CR2).

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is an example, and parameters
    should be adjusted to suit your needs.

Launch the XnView MP docker container with the following command:
```shell
docker run -d \
    --name=xnview-mp \
    -p 5800:5800 \
    -v /docker/appdata/xnview-mp:/config:rw \
    -v /home/user:/storage:rw \
    jlesage/xnview-mp
```

Where:

  - `/docker/appdata/xnview-mp`: Stores the application's configuration, state, logs, and any files requiring persistency.
  - `/home/user`: Contains files from the host that need to be accessible to the application.

Access the XnView MP GUI by browsing to `http://your-host-ip:5800`.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-xnview-mp.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/jlesage/docker-xnview-mp/issues).

For other Dockerized applications, visit https://jlesage.github.io/docker-apps.
