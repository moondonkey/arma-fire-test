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
import sys
import time
import urllib.request


def log(msg):
    """Print timestamped log message and flush immediately."""
    timestamp = time.strftime("%H:%M:%S")
    print(f"[{timestamp}] {msg}")
    sys.stdout.flush()


def poll_server(server_url):
    """Poll for pending fire mission."""
    url = f"{server_url}/api/pending"
    log(f"Polling: {url}")
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=5) as resp:
            status = resp.status
            raw = resp.read().decode()
            log(f"Vastus (HTTP {status}): {raw[:200]}")
            data = json.loads(raw)
            mission = data.get("mission")
            if mission:
                log(f"Tulekask saadud: {mission}")
            else:
                log("Tulekaske ei ole")
            return mission
    except Exception as e:
        log(f"VIGA poll: {type(e).__name__}: {e}")
        return None


def write_mission_file(filepath, mission):
    """Write fire mission to file for DLL to read."""
    line = f"{mission['x']},{mission['y']},{mission['count']},{mission['radius']},{mission['interval']}"
    log(f"Kirjutan faili: {filepath}")
    try:
        with open(filepath, "w") as f:
            f.write(line)
        log(f"OK kirjutatud: {line}")
    except Exception as e:
        log(f"VIGA faili kirjutamine: {type(e).__name__}: {e}")


def main():
    parser = argparse.ArgumentParser(description="Arma 3 Fire Mission Bridge")
    parser.add_argument("--server", default="https://arma-fire-test-production.up.railway.app", help="Test server URL")
    parser.add_argument("--out", default="E:\\Programmid\\Steam\\steamapps\\common\\Arma 3\\fire_mission.txt", help="Output file path (must match init.sqf FIRE_MISSION_PATH)")
    parser.add_argument("--poll-interval", type=float, default=1.0, help="Poll interval in seconds (default: 1.0)")
    args = parser.parse_args()

    log("Bridge kaivitatud")
    log(f"  Server: {args.server}")
    log(f"  Fail: {args.out}")
    log(f"  Poll intervall: {args.poll_interval}s")
    log(f"  Python: {sys.version}")
    log(f"  OS: {os.name}")
    log("Ootan tulekakse...")

    poll_nr = 0
    while True:
        poll_nr += 1

        if os.path.exists(args.out):
            log(f"#{poll_nr} Fail eksisteerib, ootan kustutamist: {args.out}")
            time.sleep(args.poll_interval)
            continue

        log(f"#{poll_nr} Kusin serverilt...")
        mission = poll_server(args.server)
        if mission:
            write_mission_file(args.out, mission)

        time.sleep(args.poll_interval)


if __name__ == "__main__":
    main()
