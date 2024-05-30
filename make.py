# noqa: ignore
from __future__ import annotations
import sys
from pathlib import Path
import subprocess
import logging

from makepyz import api

log = logging.getLogger(__name__)

PLATFORMS = [
    "linux/arm/v7",
    "linux/arm64",
    "linux/amd64"
]

def run(cmd):
    args: list[str] = [str(c) for c in ([cmd] if isinstance(cmd, str) else cmd)]
    return subprocess.check_call(args, encoding="utf-8")


def dkrun(platform, image, *cmds, mountpoints=True):
    result = [ f"docker run --platform {platform}", ]

    if mountpoints is True:
        mountpoints = [
            f"{BASEDIR}/scripts:/scripts",
            f"{BUILDIR}:/build",
        ]

    for mountpoint in  (mountpoints or []):
        result.append(f"-v {mountpoint}")
    result.append(f"--rm -ti {image}")
    result.extend(cmds)
    return " ".join(result)

@api.task(name="build-sdk")
def build_sdk(arguments: list[str]):
    cache = BUILDDIR / "cache"  # noqa: ignore
    cache.mkdir(parents=True, exist_ok=True)
    sysroot = BUILDDIR / "sysroot"  # noqa: ignore
    sysroot.mkdir(parents=True, exist_ok=True)
    (sysroot / "src").mkdir(parents=True, exist_ok=True)

    if not (path := (cache / "sdk.touch" )).exists():
        run(["docker", "buildx", "build", "--platform", ",".join(PLATFORMS), "--push",
            "--file", "dkfiles/Dockerfile.sdk", "-t", "cavallo71/upython-sdk", "."])
        path.write_text("")

    if sys.platform == "win32":
        print(f"""👉 run: 

docker run --platform linux/arm/v7 ^
  -v {BUILDDIR / 'sysroot' }:/build ^
  -v {Path.cwd() / 'scripts'}:/build/scripts ^
  -ti --rm cavallo71/upython-sdk bash
""")

