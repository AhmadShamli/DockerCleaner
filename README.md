# Docker Cleanup Utility

A safe, interactive Bash utility to reclaim disk space used by Docker images, containers, volumes, and build cache.

Designed for VPS and production environments where Docker storage growth must be controlled and auditable.

---

## Features

- Shows initial disk usage
- Displays detailed `docker system df` breakdown
- Offers two cleanup modes:
  - Step-by-step (interactive confirmation)
  - Single automatic run
- Displays before/after storage comparison
- Does NOT remove running containers
- Root permission check
- Production-safe defaults

---

## Why This Exists

Docker build cache and unused images can silently consume tens or hundreds of gigabytes.

This tool provides:

- Transparency before deletion
- Controlled cleanup flow
- Measurable storage recovery
- Reduced risk in production systems

---

## Usage

### 1. Make executable

```bash
chmod +x docker-cleanup.sh
```

### 2. Run as root

```bash
sudo ./docker-cleanup.sh
```

---

## Cleanup Modes

### 1) Step-by-step

Prompts before each action:

- Remove stopped containers
- Remove unused images
- Remove unused volumes
- Remove build cache

Recommended for production systems.

---

### 2) Single automatic run

Executes:

```bash
docker system prune -a --volumes -f
docker builder prune -a -f
```

Recommended for CI or non-critical environments.

---

## Example Output

Before:

```
Images:        65GB
Build Cache:   47GB
```

After:

```
Images:        16GB
Build Cache:   0B
```

---

## Requirements

- Linux
- Docker installed
- Root privileges

---

## Recommended Production Practice

Add a weekly cron job to prevent storage growth:

```bash
0 3 * * 0 docker builder prune -a -f
```

---

## Author

GitHub: https://github.com/AhmadShamli

---

## License

MIT License

Copyright (c) 2026 Ahmad Shamli

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
