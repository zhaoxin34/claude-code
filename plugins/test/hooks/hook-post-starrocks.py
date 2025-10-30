#!/usr/bin/env python3
import json
import sys

# 如果是read md或txt，自动过
#
# Load input from stdin
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
tool_input = input_data.get("tool_input", {})

print(f"tool_name: {tool_name}")
print(f"tool_input: {tool_input}")

sys.exit(2)
