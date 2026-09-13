# MoSA public website

The public Museum of Stolen Artefacts website, built with Astro. The initial app is a minimal holding page; visual design and collection browsing will be developed here.

## Development

From the repository root, after `mise install` and `mise exec -- just install`:

```sh
just website-dev
just website-check
just website-build
just website-preview
```

Use `mise exec -- just ...` if mise is not activated. The development and preview port is 4322, alongside the explorer on 4321. Build output is `apps/website/dist/`.

The app uses static output and requires no database or secrets. It owns its routes and components. Do not import explorer internals or give this app the explorer's database role. A publication-aware data interface must precede public collection features.

## Production

```sh
just website-image
docker run --rm -p 8080:8080 mosa-website:local
```

The image serves static output through nginx as an unprivileged user. The build context must be the repository root. The website workflow verifies and builds this image independently; its manual deployment requires the hosting configuration described in [deployment](../../docs/deployment.md).
