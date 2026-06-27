[![Latest](https://ghcr-badge.egpl.dev/simons-containers/distroless-authelia/latest_tag?ignore=latest,sha256*&label=latest)  
![Size](https://ghcr-badge.egpl.dev/simons-containers/distroless-authelia/size?tag=latest)  
![Tags](https://ghcr-badge.egpl.dev/simons-containers/distroless-authelia/tags?ignore=latest,sha256*)](https://github.com/simons-containers/distroless-authelia/pkgs/container/distroless-authelia)  

# Distroless authelia container

Bare-bones distroless authelia container image.

## Running

Configuration is loaded from .yaml files in `/etc/authelia.d`

Example:

```bash
docker run -it --rm -v ./config:/etc/authelia.d \
  ghcr.io/simons-containers/distroless-authelia:latest
```

## Building

| Arg | Description |
|---|---|
| `AUTHELIA_VERSION` | Version of authelia to use

Build container:

```bash
docker build -t \
  distroless-authelia:$(yq -r .authelia versions.yaml) \
  $(yq -r 'to_entries[] | "--build-arg " + (.key | upcase) + "_VERSION=" + .value' versions.yaml) \
  -f Containerfile .
```

## License

Repository contents (e.g., `Containerfile`, build scripts, and configuration) are licensed under the **MIT License**.

Software included in built container images (such as **authelia**, **glibc**, **tzdata**, and **Mozilla CA Certificates**) are provided under their respective upstream licenses and are not covered by the MIT license for this repository.

## Acknowledgements

This project depends on a number of upstream components and data sources:

- **authelia** - The Single Sign-On Multi-Factor portal for web apps, now OpenID Certified™.  
  https://www.authelia.com

- **glibc** – GNU C Library providing the standard C runtime and POSIX interfaces used by most Linux systems.  
  https://www.gnu.org/software/libc/

- **tzdata** – The IANA Time Zone Database, which provides the canonical global timezone definitions used for correct time handling.  
  https://www.iana.org/time-zones

- **Mozilla CA Certificates** – The curated set of trusted root Certificate Authorities maintained by Mozilla and used by many systems for TLS verification.  
  https://wiki.mozilla.org/CA
