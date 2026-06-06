#!/usr/bin/env python3
"""Submit Kunpeng PBS final-gap experiments and download parsed results."""
from __future__ import annotations

import csv
import os
import posixpath
import re
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


def parse_metrics(block: str) -> dict[str, str]:
    def match(pattern: str) -> str:
        m = re.search(pattern, block, flags=re.MULTILINE)
        return m.group(1).strip() if m else ""

    per_rank = match(r"per-rank search latency \(us\):([^\r\n]+)")
    vals = [float(m.group(1)) for m in re.finditer(r"rank\d+=([0-9.]+)", per_rank)]
    rank_min = rank_max = rank_mean = imbalance = ""
    if vals:
        rank_min_v = min(vals)
        rank_max_v = max(vals)
        rank_mean_v = sum(vals) / len(vals)
        rank_min = f"{rank_min_v:.5f}"
        rank_max = f"{rank_max_v:.5f}"
        rank_mean = f"{rank_mean_v:.5f}"
        imbalance = f"{(rank_max_v / rank_mean_v if rank_mean_v else 0.0):.5f}"

    thread_line = match(r"mpi_thread_requested=([^\r\n]+)")
    thread_requested = thread_provided = ""
    m = re.match(r"([^,]+),\s*mpi_thread_provided=(.+)", thread_line)
    if m:
        thread_requested = m.group(1).strip()
        thread_provided = m.group(2).strip()

    return {
        "recall": match(r"average recall:\s*([0-9.]+)"),
        "latency_us": match(r"average latency \(us\):\s*([0-9.]+)"),
        "max_local_us": match(r"max local search latency \(us\):\s*([0-9.]+)"),
        "comm_merge_us": match(r"comm\+merge latency \(us\):\s*([0-9.]+)"),
        "rank_min_us": rank_min,
        "rank_max_us": rank_max,
        "rank_mean_us": rank_mean,
        "imbalance": imbalance,
        "comm_mode": match(r"comm_mode=([^\r\n]+)"),
        "thread_requested": thread_requested,
        "thread_provided": thread_provided,
        "base_partition": match(r"base_partition=([^,\r\n]+)"),
        "header": match(r"([^\r\n]*mpi_procs=[^\r\n]*)"),
        "per_rank_us": per_rank,
    }


def parse_log(log_path: Path, csv_path: Path) -> None:
    text = log_path.read_text(encoding="utf-8", errors="replace")
    blocks = re.split(r"(?m)^---\s*$", text)
    rows: list[dict[str, str]] = []
    for block in blocks:
        case = re.search(r"CASE:\s+(\S+)\s+(\S+)", block)
        if not case:
            continue
        experiment = case.group(1)
        label = case.group(2)
        algorithm = "Block-HNSW" if experiment == "load_balance" else "IVF-PQ"
        metrics = parse_metrics(block)
        rows.append(
            {
                "platform": "Kunpeng PBS",
                "experiment": experiment,
                "case": label,
                "algorithm": algorithm,
                "np": "8",
                "nthreads": "2",
                **metrics,
            }
        )

    fieldnames = [
        "platform",
        "experiment",
        "case",
        "algorithm",
        "np",
        "nthreads",
        "recall",
        "latency_us",
        "max_local_us",
        "comm_merge_us",
        "rank_min_us",
        "rank_max_us",
        "rank_mean_us",
        "imbalance",
        "comm_mode",
        "thread_requested",
        "thread_provided",
        "base_partition",
        "header",
        "per_rank_us",
    ]
    with csv_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"saved {csv_path}", flush=True)


def main() -> int:
    if not PASSWORD:
        print("Set KUNPENG_PASSWORD before running this script.", file=sys.stderr)
        return 2
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    remote_log = f"results/kunpeng_pbs_final_gaps_{timestamp}.txt"
    RESULTS.mkdir(exist_ok=True)
    jump = target = None
    try:
        jump, target = connect()
        sftp = target.open_sftp()
        sftp.put(str(BASE / "main.cc"), posixpath.join(REMOTE_DIR, "main.cc"))
        sftp.put(
            str(BASE / "scripts" / "qsub_mpi_final_gaps.sh"),
            posixpath.join(REMOTE_DIR, "scripts/qsub_mpi_final_gaps.sh"),
        )
        sftp.close()
        run(target, f"cd {REMOTE_DIR} && make clean && make", timeout=300)
        job = run(
            target,
            f"cd {REMOTE_DIR} && rm -f final_gaps.o final_gaps.e && "
            f"qsub -v NP=8,OMP_NUM_THREADS=2,QUERY_N=2000 "
            f"scripts/qsub_mpi_final_gaps.sh",
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
            f"(echo 'Kunpeng PBS final gap experiments'; "
            f"echo 'Date: '$(date '+%Y-%m-%d %H:%M:%S'); "
            f"echo 'JOB: {job}'; "
            f"echo '--- final_gaps.o'; cat final_gaps.o; "
            f"echo '--- final_gaps.e'; cat final_gaps.e 2>/dev/null || true) > {remote_log}",
            timeout=120,
        )
        local_log = RESULTS / posixpath.basename(remote_log)
        sftp = target.open_sftp()
        sftp.get(posixpath.join(REMOTE_DIR, remote_log), str(local_log))
        sftp.close()
        print(f"saved {local_log}", flush=True)
        parse_log(local_log, RESULTS / f"kunpeng_pbs_final_gaps_{timestamp}.csv")
        return 0
    finally:
        if target:
            target.close()
        if jump:
            jump.close()


if __name__ == "__main__":
    raise SystemExit(main())
