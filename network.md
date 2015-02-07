# NETWORK

#### Parallel pings

```bash
#!/bin/bash
# Filename: fast_ping.sh
for ip in 192.168.224.{1..2} ;
do
    (
        ping $ip -c2 &> /dev/null ;
        if [ $? -eq 0 ];
            then echo $ip is alive
        fi
    )&
    done
wait
```

How it works...<br>
In the first method, we used the ping command to find out the alive machines on the <br>
network. We used a for loop for iterating through a list of IP addresses generated using<br>
the expression ```192.168.224.{1..2}```. The ```{start..end}``` notation will expand and will<br>
generate a list of IP addresses<br>
```ping $ip -c 2 &> /dev/null``` will run a ping command to the corresponding IP address<br>
in each execution of the loop. The -c option is used to restrict the number of echo packets to<br>
be sent to a specified number. ```&> /dev/null``` is used to redirect both stderr and stdout<br>
to /dev/null so that it won't be printed on the terminal. Using ```$?``` we evaluate the exit<br>
status. If it is successful, the exit status is 0 else non-zero. Hence, the IP addresses which<br>
replied to our ping are printed.

#### Running commands on a remote host with SSH

It can be generalized as:
```bash
COMMANDS="command1; command2; command3"
ssh user@hostname "$COMMANDS"
```
Let's write an SSH-based shell script that collects the uptime of a list of remote hosts.
```bash
#!/bin/bash
#Filename: uptime.sh
#Description: Uptime monitor
IP_LIST="192.168.0.1 192.168.0.5 192.168.0.9"
USER="test"
for IP in $IP_LIST;
do
  utime=$(ssh ${USER}@${IP} uptime | awk '{ print $3 }' )
  echo $IP uptime: $utime
done
```
The SSH protocol also supports data transfer with compression, <br>
which comes in handy when bandwidth is an issue.<br>
Use the -C option with the ssh command to enable compression as follows:<br>
```$ ssh -C user@hostname COMMANDS```

#### Redirecting data into stdin of remote host shell commands<br>
Sometimes, we need to redirect some data into stdin of remote shell commands.<br>
Let's see how to do it. An example is as follows:<br>
```bash
echo 'text' | ssh user@remote_host 'echo'
text
Or
# Redirect data from file as:
ssh user@remote_host 'echo' < file
```
echo on the remote host prints the data received through stdin which in turn is passed to
stdin from localhost.

