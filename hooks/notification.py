#!/usr/bin/env python3
import asyncio
from audio_utils import play_audio_async


async def main():
    """Main function to handle subagent stop event"""
    # Play success2 sound asynchronously
    await play_audio_async("incomplete.mp3")

    # You can add additional logic here if needed
    # For example, logging, cleanup, notifications, etc.


if __name__ == "__main__":
    asyncio.run(main())
