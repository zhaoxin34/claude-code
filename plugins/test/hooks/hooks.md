# https://docs.claude.com/en/docs/claude-code/hooks

# UserPromptSubmit Input

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate the factorial of a number"
}
```

# Hook Output

## 返回值：exit code

* code 0: 表示成功，输出不显示，除了 UserPromptSubmit
* code 2: Block. stderr输出到屏幕.
* 其他code：错误会输出，但不会block.

## 高级json返回

```json
{
  "continue": true, // Whether Claude should continue after hook execution (default: true)
  "stopReason": "string", // Message shown when continue is false

  "suppressOutput": true, // Hide stdout from transcript mode (default: false)
  "systemMessage": "string" // Optional warning message shown to the user
}
```


