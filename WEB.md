# WGET / cURL 

#### You can specify a different logfile path rather than printing logs to stdout , by using the -o option:
```bash
wget ftp://example_domain.com/somefile.img -O dloaded_file.img -o log
```

#### Download some patch if you prefer to be prompted for the password
```bash
wget --ask-password -O SOME.patch https://LOGIN@git.com/SOME.git/patch/?id=dd9d9f02e21c22a36ec2b69a
```

#### To specify the number of tries, use the -t flag as follows:
```bash
wget -t 5 URL
```
#### Or to ask wget to keep trying infinitely, use -t as follows:
```bash
wget -t 0 URL
```
#### We can restrict the speed limits in wget by using the --limit-rate argument as follows:
```wget --limit-rate 20k http://example.com/file.iso   OR   $ curl URL --limit-rate 20k```
#### If a download using wget gets interrupted before it is complete, we can resume the download
#### from where we left off by using the -c option as follows:
```bash
wget -c URL
```
#### Some web pages require authentication for HTTP or FTP URLs. <br>
#### It can be obtained by using the --user and --password arguments:
```bash
wget --user username --password pass URL
curl -u user:pass URL 
```
#### If you prefer to be prompted for the password 
```bash
curl -u user URL
curl http://example.com --cookie "user=slynux;pass=hack"
curl -H "Host: www.slynux.org" -H "Accept-language: en" URL
```
#### Get info about IP address  
```bash 
curl -s http://www.telize.com/ip
curl --silent http://api.2ip.com.ua/geo.json?ip=94.153.118.38 | tr "," "\n"
curl -s http://www.telize.com/geoip/8.8.8.8 | tr "," "\n"
```
