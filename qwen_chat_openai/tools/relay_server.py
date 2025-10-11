import asyncio
import json
import os
from urllib.parse import urlparse, parse_qs

import websockets


rooms = {}  # room_id -> set of websocket


async def handler(ws, path):
    try:
        # Parse room from query string
        url = urlparse(path)
        qs = parse_qs(url.query)
        room = (qs.get('room') or ['default'])[0]
        peers = rooms.setdefault(room, set())
        peers.add(ws)
        async for msg in ws:
            # Broadcast to all peers except sender
            for peer in list(peers):
                if peer is ws:
                    continue
                try:
                    await peer.send(msg)
                except Exception:
                    pass
    finally:
        # Cleanup
        for s in rooms.values():
            s.discard(ws)


async def main():
    host = os.environ.get('RELAY_HOST', '0.0.0.0')
    port = int(os.environ.get('RELAY_PORT', '8765'))
    async with websockets.serve(handler, host, port):
        print(f"Relay running on ws://{host}:{port}")
        await asyncio.Future()  # run forever


if __name__ == '__main__':
    asyncio.run(main())


