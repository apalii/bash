# BASH
Tips, Tricks &amp; Techniques

Another useful info for day-to-day routine.

-------------------------------------------------------------
Send a message to a particular rsyslog instance:

```bash
# echo -e "<14>127.0.0.1 Test\tmessage TCP" | nc -v -w 1 192.168.87.199 515
# echo -e "<14>127.0.0.1 Test\tmessage UDP " | nc -v -u -w 1 localhost 514
```
