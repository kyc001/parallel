#!/usr/bin/env python3
"""
Automated Kunpeng server testing using paramiko for SSH automation
"""

import paramiko
import time
import sys
from datetime import datetime

# Configuration
JUMP_HOST = "10.137.144.91"
JUMP_PORT = 9001
TARGET_HOST = "192.168.90.141"
USERNAME = "s2413575"
PASSWORD = "s2413575"

def create_ssh_client(hostname, port, username, password):
    """Create and connect SSH client"""
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, port=port, username=username, password=password,
                   timeout=30, look_for_keys=False, allow_agent=False)
    return client

def execute_command(client, command, timeout=300):
    """Execute command and return output"""
    stdin, stdout, stderr = client.exec_command(command, timeout=timeout)
    exit_status = stdout.channel.recv_exit_status()
    output = stdout.read().decode('utf-8')
    error = stderr.read().decode('utf-8')
    return exit_status, output, error

def main():
    print("=== Connecting to Kunpeng server via jump host ===")

    try:
        # Connect to jump host
        print(f"Connecting to jump host {JUMP_HOST}:{JUMP_PORT}...")
        jump_client = create_ssh_client(JUMP_HOST, JUMP_PORT, USERNAME, PASSWORD)
        print("[OK] Connected to jump host")

        # Create tunnel through jump host
        jump_transport = jump_client.get_transport()
        dest_addr = (TARGET_HOST, 22)
        local_addr = (JUMP_HOST, JUMP_PORT)
        jump_channel = jump_transport.open_channel("direct-tcpip", dest_addr, local_addr)

        # Connect to target through tunnel
        print(f"Connecting to target {TARGET_HOST} through tunnel...")
        target_client = paramiko.SSHClient()
        target_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        target_client.connect(TARGET_HOST, username=USERNAME, password=PASSWORD,
                            sock=jump_channel, look_for_keys=False, allow_agent=False)
        print("[OK] Connected to target server")

        # Upload main.cc
        print("\n=== Uploading files ===")
        sftp = target_client.open_sftp()

        print("Uploading main.cc...")
        sftp.put("main.cc", "/home/s2413575/ann-mpi/main.cc")
        print("[OK] main.cc uploaded")

        print("Uploading test script...")
        sftp.put("scripts/run_blocking_vs_nonblocking_kunpeng.sh",
                "/home/s2413575/ann-mpi/scripts/run_blocking_vs_nonblocking_kunpeng.sh")
        print("[OK] Script uploaded")

        sftp.close()

        # Build
        print("\n=== Building on Kunpeng ===")
        status, output, error = execute_command(target_client,
            "cd ~/ann-mpi && make clean && make", timeout=60)

        if status != 0:
            print(f"Build failed with status {status}")
            print("Error:", error)
            return 1

        print("[OK] Build successful")
        print(output)

        # Run experiments
        print("\n=== Running experiments (this will take 10-15 minutes) ===")
        status, output, error = execute_command(target_client,
            "cd ~/ann-mpi && chmod +x scripts/run_blocking_vs_nonblocking_kunpeng.sh && "
            "bash scripts/run_blocking_vs_nonblocking_kunpeng.sh",
            timeout=1200)  # 20 minutes timeout

        if status != 0:
            print(f"Experiments failed with status {status}")
            print("Error:", error)
            return 1

        print("[OK] Experiments completed")

        # Find result file
        print("\n=== Downloading results ===")
        status, output, error = execute_command(target_client,
            "ls -t ~/ann-mpi/results/blocking_vs_nonblocking_kunpeng_*.txt 2>/dev/null | head -1")

        if status != 0 or not output.strip():
            print("No result file found")
            return 1

        remote_file = output.strip()
        local_file = f"results/{remote_file.split('/')[-1]}"

        print(f"Downloading {remote_file}...")
        sftp = target_client.open_sftp()
        sftp.get(remote_file, local_file)
        sftp.close()

        print(f"[OK] Results downloaded to {local_file}")

        # Cleanup
        target_client.close()
        jump_client.close()

        print("\n=== Done! ===")
        return 0

    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
