"""
Arma 3 Fire Mission Bridge
Polls the test server for pending fire missions and writes them
as files that the Arma 3 SQF script can read.

Usage:
    python bridge.py --server https://your-railway-url.up.railway.app --arma-dir "C:/path/to/arma3/mpmissions/your_mission.map"

The bridge writes fire_mission.txt into the Arma 3 mission directory.
The SQF script reads and deletes it.
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
        print(f"[VIGA] Server poll ebaõnnestus: {e}")
        return None

def write_mission_file(arma_dir, mission):
    """Write fire mission to file for SQF to read."""
    filepath = os.path.join(arma_dir, "fire_mission.txt")
    # Format: x,y,count,radius,interval
    line = f"{mission['x']},{mission['y']},{mission['count']},{mission['radius']},{mission['interval']}"
    with open(filepath, "w") as f:
        f.write(line)
    print(f"[OK] Tulekäsk kirjutatud: {line}")

def main():
    parser = argparse.ArgumentParser(description="Arma 3 Fire Mission Bridge")
    parser.add_argument("--server", required=True, help="Test server URL (e.g. https://xxx.up.railway.app)")
    parser.add_argument("--arma-dir", required=True, help="Path to Arma 3 mission directory")
    parser.add_argument("--poll-interval", type=float, default=1.0, help="Poll interval in seconds (default: 1.0)")
    args = parser.parse_args()

    if not os.path.isdir(args.arma_dir):
        print(f"[VIGA] Arma kausta ei leitud: {args.arma_dir}")
        return

    print(f"Bridge käivitatud")
    print(f"  Server: {args.server}")
    print(f"  Arma kaust: {args.arma_dir}")
    print(f"  Poll intervall: {args.poll_interval}s")
    print(f"Ootan tulekäske...")

    while True:
        mission = poll_server(args.server)
        if mission:
            write_mission_file(args.arma_dir, mission)
        time.sleep(args.poll_interval)

if __name__ == "__main__":
    main()
