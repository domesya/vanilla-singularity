# AGENTS.md

## What this repo is
- This is a **Vanilla OS Vib image recipe**, not an application. There is no local app server, `package.json`, or test suite; the artifact is an OCI image.
- `recipe.yml` is the entrypoint. Modules only run when listed under `stages[].modules[].includes`; adding a file in `modules/` is not enough.
- The goal is a GNOME-free Singularity Desktop flavor (`singularityos-lab/singularity-desktop`). `README.md` is still the stock custom-image template; do not treat it as current design.
- The base is `ghcr.io/vanilla-os/core:latest`, which has no GNOME. Do not add GNOME/desktop modules expecting them to exist.
- The tree is mid-migration: run `git status` first. Untracked `modules/20-vetro.yml`, `21-singularity-deps.yml`, `22-singularity-build.yml` and the new scripts are WIP.

## Build and verification
- CI is the source of truth: `.github/workflows/vib-build.yml` runs `vanilla-os/vib-gh-action@v1.0.7`. Keep `recipe.yml` `vibversion` in sync with the action version.
- There are no local lint/test/typecheck commands. Do not invent `npm`, `make test`, or similar.
- YAML formatting is `yamlfmt` with `.yamlfmt`; run `yamlfmt .` if it is installed.
- `Containerfile`, `downloads/`, `plugins/`, and `sources/` are Vib-generated and gitignored; never commit them.
- A tag triggers `.github/workflows/release.yml`, which also generates `Containerfile` from the recipe.

## Recipe rules that are easy to get wrong
- `addincludes: true` copies `includes.container/` into `/` of the image. `image-info/base-image-name` and `image-info/image-name` are placeholders overwritten by CI.
- Module order matters. The final `cleanup-and-sysconf-setup` shell runs `rm -rf /usr/share/scripts`, `lpkg --lock`, and `rsync /etc /sysconf`; anything using `/usr/share/scripts` must run before it.
- `modules/999-cleanup.yml` and `997-misc-setup.yml` run late. Avoid package/file removals that break earlier layers, and use `rm -f` when a target may already be absent.
- The CI base-update check reads `fy-filter ... /stages/-1/base`. Do not add a trailing stage: the current `initrd` stage makes it read `build` and fail. Fix the workflow path if a trailing stage is truly required.
- `includes.container/usr/share/abroot/abroot.json` pins tag `main`; the workflow publishes the `main` branch tag. Changing release tags requires updating ABRoot config too.
- `only-arches` is used for arch-specific sources. CI builds `amd64` and `arm64`; keep both in mind when adding packages or sources.
- Preserve existing upstream tags and checksums. Add a `checksum` for any new download.

## Upstream references
- Vanilla recipes: `Vanilla-OS/desktop-image`, `Vanilla-OS/core-image`, template `Vanilla-OS/custom-image`.
- Singularity Desktop build instructions live in `singularityos-lab/singularity-desktop` `README.md` and `Containerfile`. Vetro is a subproject; build it from source with Go rather than downloading it ad hoc.
- Vanilla first-setup is GNOME-specific (`gnome-session --session=firstsetup`) and cannot be reused unchanged in a GNOME-free image.
- Do not mix display managers: Singularity's `scripts/install-greeter.sh` targets `greetd`, while `install-session.sh` targets GDM.
- The official Singularity OCI build installs to `/opt/singularity`; upstream native scripts detect `/opt/local`. Confirm the prefix before calling them.

## Git and credentials
- `origin` is `github.com/domesya/vanillaos-singularity`. A second local remote is credential-bearing; do not push through it or copy its URL into files.
- Never commit or echo tokens. Revoke any credential found in a remote URL.
