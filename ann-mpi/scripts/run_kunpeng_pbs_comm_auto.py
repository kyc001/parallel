#!/usr/bin/env python3
"""Submit a Kunpeng PBS blocking/non-blocking MPI comparison and download it."""
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
REMOTE_DIR = f"/home/{USER}/ann-mpi"
BASE = Path(__file__).resolve().parent.parent
RESULTS = BASE / "results"


def connect() -> tuple[paramiko.SSHClient, paramiko.SSHClient]:
    jump = paramiko.SSHClient()
    jump.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    jump.connect(JUMP_HOST, port=JUMP_PORT, username=USER, password=PASSWORD,
                 timeout=30, look_for_keys=False, allow_agent=False)
    channel = jump.get_transport().open_channel(
        "direct-tcpip", (TARGET_HOST, 22), (JUMP_HOST, JUMP_PORT)
    )
    target = paramiko.SSHClient()
    target.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    target.connect(TARGET_HOST, username=USER, password=PASSWORD, sock=channel,
                   timeout=30, look_for_keys=False, allow_agent=False)
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


def main() -> int:
    if not PASSWORD:
        print("Set KUNPENG_PASSWORD before running this script.", file=sys.stderr)
        return 2
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    remote_log = f"results/kunpeng_pbs_comm_modes_{timestamp}.txt"
    RESULTS.mkdir(exist_ok=True)
    jump = target = None
    try:
        jump, target = connect()
        sftp = target.open_sftp()
        sftp.put(str(BASE / "main.cc"), posixpath.join(REMOTE_DIR, "main.cc"))
        sftp.put(str(BASE / "scripts" / "qsub_mpi_comm_modes.sh"),
                 posixpath.join(REMOTE_DIR, "scripts/qsub_mpi_comm_modes.sh"))
        sftp.close()
        run(target, f"cd {REMOTE_DIR} && make clean && make", timeout=300)
        job = run(
            target,
            f"cd {REMOTE_DIR} && rm -f comm.o comm.e && "
            f"qsub -v NP=8,OMP_NUM_THREADS=2,QUERY_N=2000 scripts/qsub_mpi_comm_modes.sh",
        ).strip().splitlines()[-1].strip()
        print(f"submitted job: {job}", flush=True)
        deadline = time.time() + 60 * 45
        while time.time() < deadline:
            out = run(target, f"qstat {job} 2>/dev/null || true", timeout=60)
            if not out.strip() or " C " in out or out.splitlines()[-1].split()[4:5] == ["C"]:
                break
            time.sleep(10)
        else:
            raise TimeoutError(f"PBS job did not finish before timeout: {job}")
        run(
            target,
            f"cd {REMOTE_DIR} && "
            f"(echo 'Kunpeng PBS comm mode validation'; "
            f"echo 'Date: '$(date '+%Y-%m-%d %H:%M:%S'); "
            f"echo 'JOB: {job}'; "
            f"echo '--- comm.o'; cat comm.o; "
            f"echo '--- comm.e'; cat comm.e 2>/dev/null || true) > {remote_log}",
            timeout=120,
        )
        local_log = RESULTS / posixpath.basename(remote_log)
        sftp = target.open_sftp()
        sftp.get(posixpath.join(REMOTE_DIR, remote_log), str(local_log))
        sftp.close()
        print(f"saved {local_log}", flush=True)
        return 0
    finally:
        if target:
            target.close()
        if jump:
            jump.close()


if __name__ == "__main__":
    raise SystemExit(main())
