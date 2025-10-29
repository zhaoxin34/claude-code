#!/usr/bin/env python3
import subprocess
import sys
import os


async def play_audio_async(filename: str):
    """Asynchronously play an audio file from the resources directory"""
    try:
        audio_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)), "resources", filename
        )
        if os.path.exists(audio_path):
            # Use platform-specific audio playback
            if sys.platform == "darwin":
                subprocess.Popen(
                    ["afplay", audio_path],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            elif sys.platform == "linux":
                subprocess.Popen(
                    ["aplay", audio_path],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            elif sys.platform == "win32":
                subprocess.Popen(
                    [
                        "powershell",
                        "-c",
                        f"(New-Object Media.SoundPlayer '{audio_path}').PlaySync();",
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
        else:
            # If file doesn't exist, silently continue
            pass
    except Exception:
        # If any error occurs during playback, silently continue
        pass