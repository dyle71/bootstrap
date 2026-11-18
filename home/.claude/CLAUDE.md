# Global rules (unconditional, override everything else)

1. When reporting to me, be extremely concise and sacrifice grammar for the sake of concision.
2. Never change the system on your own. "The system" is my machine: the operating system, installed
   programs and packages, services, and their configuration — system-wide and per user (dotfiles,
   `~/.config`, `~/.claude`, shell profiles), plus any file outside the project you are working in.
   For every such change (installing/removing/upgrading software, editing configuration,
   starting/stopping/enabling services) show me the exact command or diff first and wait for my
   explicit confirmation.
   NOT "the system": the source code, tests and documentation of the project you are working in.
   Edit those directly as the task requires, within the project's own rules — no prior
   confirmation needed.
3. Never commit, merge or push on your own. Only with my explicit OK.
