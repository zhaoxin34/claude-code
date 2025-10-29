# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code configuration repository that sets up a customized development environment with audio feedback, status line enhancements, and security hooks. The repository configures Claude Code to use alternative API endpoints and adds custom behaviors for different events.

## Key Commands

### Environment Setup
```bash
# Use uv for Python dependency management
uv run <script>
```

### Hook Execution
All hooks are executed using `uv run`:
```bash
uv run ./hooks/user_prompt_submit.py
uv run ./hooks/notification.py
uv run ./hooks/session_start.py
uv run ./hooks/pre_tool_use.py
uv run ./hooks/post_tool_use.py
uv run ./hooks/pre_compact.py
uv run ./hooks/stop.py
uv run ./hooks/subagent_stop.py
```

## Architecture

### Configuration Structure
- `settings.json` - Main Claude Code configuration file
- `ccline/` - Status line customization (CCometixLine)
- `hooks/` - Python scripts for event handling
- `resources/` - Audio files for feedback

### API Configuration
The repository is configured to use alternative API endpoints:
- Base URL: `https://open.bigmodel.cn/api/anthropic`
- Models mapped to GLM variants:
  - Haiku → `glm-4.5-air`
  - Sonnet → `glm-4.6`
  - Opus → `glm-4.6`

### Hook System
The repository implements a comprehensive hook system for different Claude Code events:

1. **UserPromptSubmit** - Validates prompts for sensitive information and plays success audio
2. **Notification** - Handles notification events
3. **SessionStart** - Triggered when sessions start
4. **PreToolUse/PostToolUse** - Tool usage tracking
5. **PreCompact** - Pre-compaction cleanup
6. **Stop/SubagentStop** - Cleanup events with audio feedback

### Status Line (CCometixLine)
Custom status line configuration with segments:
- Model display
- Directory
- Context window
- Usage tracking
- Session timer
- Output style
- Cost tracking (disabled)

### Security Features
- Input validation for sensitive patterns (passwords, secrets, keys, tokens)
- Automatic blocking of prompts containing potential security violations
- Audio feedback system for user experience

## Development Notes

### Python Dependencies
The hooks use Python 3 with asyncio for audio playback. No traditional package.json or requirements.txt - the project relies on `uv` for dependency management.

### Audio System
Cross-platform audio playback using system utilities:
- macOS: `afplay`
- Linux: `aplay`
- Windows: PowerShell Media.SoundPlayer

### File Structure Patterns
- Configuration files use TOML format
- Hooks are executable Python scripts
- Audio files stored in `resources/` directory
- Session data and debug information in various subdirectories