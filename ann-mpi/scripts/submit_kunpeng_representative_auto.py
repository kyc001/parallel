#!/usr/bin/env python3
"""Submit the teacher-required PBS script for the representative ANN MPI run."""
from __future__ import annotations

import os
import posixpath
import sys
import time
from pathlib import Path

import paramiko


JUMP_HOST = "10.137.144.91"
JUMP_PORT = 9001
TARGET_HOST = "192.168.90.141"
USER = "s2413575"
PASSWORD = os.environ.get("KUNPENG_PASSWORD")
REMOTE_DIR = f"/home/{USER}/ann"
BASE = Path(__file__).resolve().parent.parent
RESULTS = BASE / "results"
SOURCE_DIRS = ["mpi", "ivf", "hnsw", "simd", "omp", "pthread", "hnswlib"]
SOURCE_FILES = ["main.cc", "mpi_ann_runner.h", "Makefile", "qsub_mpi.sh"]


def connect() -> tuple[paramiko.SSHClient, paramiko.SSHClient]:
    jump = paramiko.SSHClient()
    jump.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    jump.connect(
        JUMP_HOST,
        port=JUMP_PORT,
        username=USER,
        password=PASSWORD,
        timeout=30,
        look_for_keys=False,
        allow_agent=False,
    )
    channel = jump.get_transport().open_channel(
        "direct-tcpip", (TARGET_HOST, 22), (JUMP_HOST, JUMP_PORT)
    )
    target = paramiko.SSHClient()
    target.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    target.connect(
        TARGET_HOST,
        username=USER,
        password=PASSWORD,
        sock=channel,
        timeout=30,
        look_for_keys=False,
        allow_agent=False,
    )
    return jump, target


def run(client: paramiko.SSHClient, command: str, timeout: int = 300) -> str:
    print(f"$ {command}", flush=True)
    _, stdout, stderr = client.exec_command(command, timeout=timeout)
    code = stdout.channel.recv_exit_status()
    out = stdout.read().decode("utf-8", errors="replace")
    err = stderr.read().decode("utf-8", errors="replace")
    if out:
        print(out, end="", flush=True)
    if err:
        print(err, end="", file=sys.stderr, flush=True)
    if code != 0:
        raise RuntimeError(f"command failed ({code}): {command}\n{err}")
    return out


def ensure_remote_dirs(sftp: paramiko.SFTPClient, path: str) -> None:
    cur = ""
    for part in path.strip("/").split("/"):
        if not part:
            continue
        cur = f"{cur}/{part}"
        try:
            sftp.stat(cur)
        except FileNotFoundError:
            sftp.mkdir(cur)


def upload_file(sftp: paramiko.SFTPClient, local: Path, remote_rel: str) -> None:
    remote = posixpath.join(REMOTE_DIR, remote_rel)
    ensure_remote_dirs(sftp, posixpath.dirname(remote))
    print(f"upload {remote_rel}", flush=True)
    sftp.put(str(local), remote)


def upload_sources(target: paramiko.SSHClient) -> None:
    sftp = target.open_sftp()
    try:
        for rel in SOURCE_FILES:
            upload_file(sftp, BASE / rel, rel)
        for rel_dir in SOURCE_DIRS:
            local_dir = BASE / rel_dir
            if not local_dir.exists():
                continue
            for local in local_dir.rglob("*"):
                if local.is_file():
                    rel = str(local.relative_to(BASE)).replace("\\", "/")
                    upload_file(sftp, local, rel)
    finally:
        sftp.close()


def job_finished(qstat_output: str, job: str) -> bool:
    text = qstat_output.strip()
    if not text:
        return True
    job_prefix = job.split(".")[0]
    for line in text.splitlines():
        parts = line.split()
        if parts and parts[0].startswith(job_prefix):
            return len(parts) > 4 and parts[4] == "C"
    return False


def main() -> int:
    if not PASSWORD:
        print("Set KUNPENG_PASSWORD before running this script.", file=sys.stderr)
        return 2

    timestamp = time.strftime("%Y%m%d_%H%M%S")
    remote_summary = f"results/kunpeng_pbs_representative_submission_{timestamp}.txt"
    local_summary = RESULTS / posixpath.basename(remote_summary)
    RESULTS.mkdir(exist_ok=True)

    jump = target = None
    try:
        jump, target = connect()
        run(target, f"mkdir -p {REMOTE_DIR}/results")
        upload_sources(target)
        run(target, f"cd {REMOTE_DIR} && make clean && make", timeout=300)

        job = run(
            target,
            f"cd {REMOTE_DIR} && rm -f test.o test.e && qsub qsub_mpi.sh",
            timeout=60,
        ).strip().splitlines()[-1].strip()
        print(f"submitted job: {job}", flush=True)

        deadline = time.time() + 60 * 45
        while time.time() < deadline:
            out = run(target, f"qstat {job} 2>/dev/null || true", timeout=60)
            if job_finished(out, job):
                break
            time.sleep(10)
        else:
            raise TimeoutError(f"PBS job did not finish before timeout: {job}")

        run(
            target,
            f"cd {REMOTE_DIR} && "
            f"(echo 'Kunpeng PBS representative submission'; "
            f"echo 'Date: '$(date '+%Y-%m-%d %H:%M:%S'); "
            f"echo 'JOB: {job}'; "
            f"echo 'COMMAND: qsub qsub_mpi.sh'; "
            f"echo '--- test.o'; cat test.o 2>/dev/null || true; "
            f"echo '--- test.e'; cat test.e 2>/dev/null || true) > {remote_summary}",
            timeout=120,
        )

        sftp = target.open_sftp()
        try:
            print(f"download {remote_summary} -> {local_summary}", flush=True)
            sftp.get(posixpath.join(REMOTE_DIR, remote_summary), str(local_summary))
            for name in ["test.o", "test.e"]:
                local_copy = RESULTS / (
                    f"kunpeng_pbs_representative_submission_{timestamp}_{name}"
                )
                print(f"download {name} -> {local_copy}", flush=True)
                sftp.get(posixpath.join(REMOTE_DIR, name), str(local_copy))
        finally:
            sftp.close()

        print(f"saved {local_summary}", flush=True)
        return 0
    finally:
        if target:
            target.close()
        if jump:
            jump.close()


if __name__ == "__main__":
    raise SystemExit(main())
