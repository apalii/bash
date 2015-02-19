# find

### Search based on filename or regular expression match

The -name argument specifies a matching string for the filename. We can pass wildcards
as its argument text. The *.txt command matches all the filenames ending with .txt and
prints them. The -print option prints the filenames or file paths in the terminal that matches
the conditions (for example, -name) given as options to the find command.
```bash
$ find /home/slynux -name "*.txt" -print
```
The find command has an option -iname (ignore case), which is similar to -name but it
matches filenames while ignoring the case.

If we want to match either of the multiple criteria, we can use OR conditions as shown in
the following:
```bash
$ ls
new.txt some.jpg text.pdf
$ find . \( -name "*.txt" -o -name "*.pdf" \) -print
./text.pdf
./new.txt
```
The previous command will print all of the .txt and .pdf files, since the find command
matches both .txt and .pdf files. \( and \) are used to treat `-name "*.txt" -o
-name "*.pdf"` as a single unit.

### Negating arguments
find can also exclude things that match a pattern using ```!```  :
```bash
$ find . ! -name "*.txt" -print
```

### Search based on the directory depth
When the find command is used, it recursively walks through all the subdirectories as
much as possible, until it reaches the leaf of the subdirectory tree. <br>We can restrict the
depth to which the find command traverses using some depth parameters given to
find. `-maxdepth` and `-mindepth` are the parameters

```bash
$ find . -maxdepth 1  -name "*.py"
$ find . -maxdepth 1  ! -name "*.py"
```
### Search based on file type
Unix-like operating systems treat every object as a file. <br>There are different kinds of files, such
as regular file, directory, character devices, block devices, symlinks, hardlinks, sockets, FIFO,
and so on.
The file search can be filtered out using the -type option. By using -type, we can specify to
the find command that it should only match files having a specified type.
```
Regular file              f
Symbolic link             l
Directory                 d
Character special device  c
Block device              b
Socket                    s
FIFO                      p
```
List only directories including descendants as follows:
```bash
$ find . -type d -print
```
It is hard to list directories and files separately. <br>But find helps to do it. List only regular files
as follows:
```bash
$ find . -type f -print
```
### Search on file times
Unix/Linux filesystems have three types of timestamps on each file. They are as follows:
- Access time (-atime): It is the last timestamp of when the file was accessed
by a user
- Modification time (-mtime): It is the last timestamp of when the file content
was modified
- Change time (-ctime): It is the last timestamp of when the metadata for a file
(such as permissions or ownership) was modified
```bash
#Print all the files that were accessed within the last seven days as follows:
$ find . -type f -atime -7 -print
#Print all the files that are having access time exactly seven-days old as follows:
$ find . -type f -atime 7 -print
#Print all the files that have an access time older than seven days as follows:
$ find . -type f -atime +7 -print
```
There are some other time-based parameters that use the time metric in minutes. These are
as follows:
- -amin (access time)
- -mmin (modification time)
- -cmin (change time)
<br>For example:
To print all the files that have an access time older than seven minutes, use the
following command:
```$ find . -type f -amin +7 -print```
Another good feature available with find is the -newer parameter. By using -newer, we can
specify a reference file to compare with the timestamp. We can find all the files that are newer
(older modification time) than the specified file with the -newer parameter.
For example, find all the files that have a modification time greater than that of the
modification time of a given file.txt file as follows:
```$ find . -type f -newer file.txt -print```

### Search based on file size
Based on the file sizes of the files, a search can be performed as follows:
```bash
$ find . -type f -size +2k
# Files having size greater than 2 kilobytes
$ find . -type f -size -2k
# Files having size less than 2 kilobytes
$ find . -type f -size 2k
# Files having size 2 kilobytes
```
Instead of k we can use different size units such as the following:
```
b: 512 byte blocks
c: Bytes
w: Two-byte words
k: Kilobyte (1024 bytes)
f M: Megabyte (1024 kilobytes)
f G: Gigabyte (1024 megabytes)
```
### Deleting based on the file matches
The `-delete` flag can be used to remove files that are matched by find.
Remove all the .swp files from the current directory as follows:
```$ find . -type f -name "*.swp" -delete```

### Executing commands or actions with find
The find command can be coupled with many of the other commands using the `-exec`
option. It is one of the most powerful features that comes with find.<br>
Let's have a look at the following example:
``` find . -type f -user root -exec chown slynux {} \;```
In this command, `{}` is a special string used with the -exec option. For each file match, `{}`
will be replaced with the filename for `-exec`. For example, if the find command finds two
files `test1.txt` and `test2.txt` with owner slynux, the find command will perform:
`chown slynux {}`
This gets resolved to chown slynux test1.txt and chown slynux test2.txt.
Sometimes we don't want to run the command for each file. Instead, we might
want to run it a fewer times with a list of files as parameters. For this, we use
+ instead of ; in the exec syntax.

```bash
$ find . -maxdepth 1 -type f -name "*.zip" -exec echo I have found - {} \;
I have found - ./sipvicious-0.2.8.zip
I have found - ./pjproject-2.3.zip
I have found - ./android-studio-ide-135.1641136-linux.zip
$ find . -maxdepth 1 -type f -name "*.zip" -exec echo I have found - {} \+
I have found - ./sipvicious-0.2.8.zip ./pjproject-2.3.zip ./android-studio-ide-135.1641136-linux.zip
```
To copy all the .txt files that are older than 10 days to a directory OLD, use the
following command:
```$ find . -type f -mtime +10 -name "*.txt" -exec cp {} OLD \;```
-exec with multiple commands
We cannot use multiple commands along with the -exec parameter. <br>It accepts only a single command, but we can use
a trick. Write multiple commands in a shell script (for example,commands.sh) and use it with -exec as follows:
```-exec ./commands.sh {} \;```
