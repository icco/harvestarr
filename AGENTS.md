# AGENTS.md

Guidance for coding agents working on harvestarr.

## Project Overview

A custom Docker image packaging [stream-harvestarr](https://github.com/ryakel/stream-harvestarr) with [Deno](https://deno.land/) installed for yt-dlp YouTube extraction requirements.

## Commands

```sh
docker build -t harvestarr .   # Build Docker image locally
```

## Conventions

- Keep Dockerfile layers minimal, pinned, and clean.
- PR titles and commits must follow Conventional Commits with lowercase subjects.
