# Analyzing Authentication Logs

System logs provide a historical record of events. Authentication logs (like `/var/log/auth.log`) are critical for identifying unauthorized access attempts.

:::adaptive
id: analogy
:::

## Log Structure
A typical log line contains a timestamp, host, service, and the message.

:::code
language: text
content: |
  Jul 21 08:12:01 server sshd[1234]: Failed password for root from 192.168.1.100 port 22 ssh2
:::

:::adaptive
id: extra_example
:::
