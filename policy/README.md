# Policy

What every machine running the image starts with. Leave the folder as it is to keep Amethystora's defaults.

## `agent.conf`

How far the AI agent may go, for every account: the file Amethystora reads from `/etc/amethystora/agent.conf`.

```text
# The most any account may turn on: act (the agent may make changes, asking each time), know (it may only read), off
ALLOW=know
# One account's own limit instead, one line each
ALLOW_FOR=admin:act
# How the agent's commands as root are allowed: session, minutes, each or terminal
ROOT=each
```

A machine's administrator can still change it with `ame agent lock` and `ame agent root`.

## `security`

One word, the security profile every machine starts with: `off`, `default`, `light`, `balanced` or `thorough`
(`ame security profile` describes each). No profile turns on anything that sends something away from the machine.
