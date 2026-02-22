"""
Arma 3 Fire Mission Bridge
Polls the test server for pending fire missions and writes them
as a file that the Arma 3 callExtension DLL reads.

Usage:
    python bridge.py --server https://your-railway-url.up.railway.app --out "C:\\arma3\\fire_mission.txt"

The DLL reads and deletes the file, so bridge waits until file is consumed
before writing the next mission.
"""

import argparse
import json
import os
import time
import urllib.request


def poll_server(server_url):
    """Poll for pending fire mission."""
    url = f"{server_url}/api/pending"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode())
            return data.get("mission")
    except Exception as e:
        print(f"[VIGA] Server poll ebaonnestus: {e}")
        return None


def write_mission_file(filepath, mission):
    """Write fire mission to file for DLL to read."""
    line = f"{mission['x']},{mission['y']},{mission['count']},{mission['radius']},{mission['interval']}"
    with open(filepath, "w") as f:
        f.write(line)
    print(f"[OK] Tulekask kirjutatud: {line}")


def main():
    parser = argparse.ArgumentParser(description="Arma 3 Fire Mission Bridge")
    parser.add_argument("--server", required=True, help="Test server URL")
    parser.add_argument("--out", default="C:\\arma3\\fire_mission.txt", help="Output file path (must match init.sqf FIRE_MISSION_PATH)")
    parser.add_argument("--poll-interval", type=float, default=1.0, help="Poll interval in seconds (default: 1.0)")
    args = parser.parse_args()

    print(f"Bridge kaivitatud")
    print(f"  Server: {args.server}")
    print(f"  Fail: {args.out}")
    print(f"  Poll intervall: {args.poll_interval}s")
    print(f"Ootan tulekakse...")

    while True:
        # Only write new file if previous was consumed (deleted by DLL)
        if os.path.exists(args.out):
            time.sleep(args.poll_interval)
            continue

        mission = poll_server(args.server)
        if mission:
            write_mission_file(args.out, mission)

        time.sleep(args.poll_interval)


if __name__ == "__main__":
    main()
