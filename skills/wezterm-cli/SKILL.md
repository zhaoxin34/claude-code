---
name: wezterm-cli
description: 这个Skills可以开启wezterm的新panel，向wezterm的panel发送命令，获得某个panel中的内容，非常适合用于启动长期运行的命令，如启动一个后端服务，或者执行kubectl exec -it pod_name -- bash, 然后再连续执行命令
allowed-tools: Bash(wezterm cli:*)
---

# wezterm cli 命令简介

```bash
Usage: wezterm cli [OPTIONS] <COMMAND>

Commands:
  list                     list windows, tabs and panes
  list-clients             list clients
  proxy                    start rpc proxy pipe
  tlscreds                 obtain tls credentials
  move-pane-to-new-tab     Move a pane into a new tab
  split-pane               split the current pane.
                               Outputs the pane-id for the newly created pane on success
  spawn                    Spawn a command into a new window or tab
                               Outputs the pane-id for the newly created pane on success
  send-text                Send text to a pane as though it were pasted. If bracketed paste mode is enabled in the pane, then the text will be sent as a bracketed paste
  get-text                 Retrieves the textual content of a pane and output it to stdout
  activate-pane-direction  Activate an adjacent pane in the specified direction
  get-pane-direction       Determine the adjacent pane in the specified direction
  kill-pane                Kill a pane
  activate-pane            Activate (focus) a pane
  adjust-pane-size         Adjust the size of a pane directionally
  activate-tab             Activate a tab
  set-tab-title            Change the title of a tab
  set-window-title         Change the title of a window
  rename-workspace         Rename a workspace
  zoom-pane                Zoom, unzoom, or toggle zoom state
  help                     Print this message or the help of the given subcommand(s)

Options:
      --no-auto-start  Don't automatically start the server
      --prefer-mux     Prefer connecting to a background mux server. The default is to prefer connecting to a running wezterm gui instance
      --class <CLASS>  When connecting to a gui instance, if you started the gui with `--class SOMETHING`, you should also pass that same value here in order for the client to find the correct gui instance
  -h, --help           Print help
```

## wezterm cli spawn 命令简介

```bash
Spawn a command into a new window or tab
Outputs the pane-id for the newly created pane on success

Usage: wezterm cli spawn [OPTIONS] [PROG]...

Arguments:
  [PROG]...  Instead of executing your shell, run PROG. For example: `wezterm cli spawn -- bash -l` will spawn bash as if it were a login shell

Options:
      --pane-id <PANE_ID>          Specify the current pane. The default is to use the current pane based on the environment variable WEZTERM_PANE. The pane is used to determine the current domain and window
      --domain-name <DOMAIN_NAME>
      --window-id <WINDOW_ID>      Specify the window into which to spawn a tab. If omitted, the window associated with the current pane is used. Cannot be used with `--workspace` or `--new-window`
      --new-window                 Spawn into a new window, rather than a new tab
      --cwd <CWD>                  Specify the current working directory for the initially spawned program
      --workspace <WORKSPACE>      When creating a new window, override the default workspace name with the provided name.  The default name is "default". Requires `--new-window`
  -h, --help                       Print help
```

## wezterm cli send-text 命令简介

```bash
Send text to a pane as though it were pasted. If bracketed paste mode is enabled in the pane, then the text will be sent as a bracketed paste

Usage: wezterm cli send-text [OPTIONS] [TEXT]

Arguments:
  [TEXT]  The text to send. If omitted, will read the text from stdin

Options:
      --pane-id <PANE_ID>  Specify the target pane. The default is to use the current pane based on the environment variable WEZTERM_PANE
      --no-paste           Send the text directly, rather than as a bracketed paste
  -h, --help               Print help
```

## wezterm cli get-text 命令简介

```bash
Retrieves the textual content of a pane and output it to stdout

Usage: wezterm cli get-text [OPTIONS]

Options:
      --pane-id <PANE_ID>        Specify the target pane. The default is to use the current pane based on the environment variable WEZTERM_PANE
      --start-line <START_LINE>  The starting line number. 0 is the first line of terminal screen. Negative numbers proceed backwards into the scrollback. The default value is unspecified is 0, the first line of the terminal screen
      --end-line <END_LINE>      The ending line number. 0 is the first line of terminal screen. Negative numbers proceed backwards into the scrollback. The default value if unspecified is the bottom of the the terminal screen
      --escapes                  Include escape sequences that color and style the text. If omitted, unattributed text will be returned
  -h, --help                     Print help
```

# 使用方法和规范

## 打开新终端

```bash
pane_id=$(wezterm cli spawn -- zsh)
```

## 向pane发送命令

```bash
echo -n "some command\n" | wezterm cli send-text --pane-id=$pane_id --no-paste

```

## 获取pane的输出

```bash
wezterm cli get-text --pane-id=$pane_id --start-line=-200
```

值得注意的是--start-line这个参数可以根据实际情况设置大小，但不要超过1000行；另外，因为send-text是异步的，所以get-text未必能获得所有信息，也许命令正在执行，这时，可以sleep几秒再get-text


## 规范

- 根据实际情况决定决定完成任务后要不要关闭panel, 一般没有特殊要求，都需要关闭panel

# 使用示例

## 使用wezterm cli进入k8s的一个spring boot的pod，然后获得获得该spring boot的进程id

```bash
# 开启一个新的终端pane并获得pane id
pane_id=$(wezterm cli spawn -- zsh)

# 向pane发送命令, 让pane进入k8s的pod
echo -n "kubectl exec -it -n dev-wolf wolf-manager-admin-0 -- bash\n" | wezterm cli send-text --pane-id=$pane_id --no-paste

# 向pane发送命令，获得java的进程id
echo -n "ps axu|grep java\n" | wezterm cli send-text --pane-id=$pane_id --no-paste

# 获得最近在pane执行命令的返回
wezterm cli get-text --pane-id=$pane_id --start-line=-200
```
