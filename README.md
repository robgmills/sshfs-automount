# SSHFS Automount

This provisioning tool sets up an automount for a remote SSHFS on an OS X client.

## Quickstart
Simply run the following in a Terminal:

```sh
sh -c "$(curl -fsSL https://raw.github.com/robgmills/sshfs-automount/master/install.sh)"
```

And follow the prompts!

## Pre-requisites

This is just a script that automates the configuration of an SSHFS mount using OS X's automount
capability.  As such, this script depends on:

0. Git (tested on v2.5.4)
0. OSXFUSE (tested on v2.7.3)
0. SSHFS (tested on v2.5.0)

## What this does

The script provided does the following:
0. Checks that the pre-requisite software is installed.
0. Prompts the user for configuration input
0. Clones the git repository containing template config files
0. Creates the desired directory for the SSHFS mount
0. Creates the necessary `.plist` file and add it to OS X's autostart configuration

## Disclaimer
This has been tested on my Mid-2014, Core i7, Retina Macbook Pro running Yosemite (OS X 10.10.5) *ONLY*!

*Use at your own risk.*

## License

This script is [licensed] under the [WTFPL][wtfpl]. 





[wtfpl]: http://www.wtfpl.net/
---------------------------------------------------------------------------------------------------

## [Inspiration][inspiration]

###Installing SSHFS for Mac

The easy way to install SSHFS is navigate to http://osxfuse.github.io and download two files:

OSXFUSE 2.7.3
SSHFS 2.5.0
Also, you can use homebrew, but, in this moment, the OSXFUSE version is still the 2.7.3 and you can have problems using the automount.

### Deactivating the automount

To deactivate the automount, I only need to edit the file /etc/auto_master and comment the line starting with /home auto_home.... After that, I ran sudo automount -vc to tell the daemon that the configuration file was changed. I unmount the /home folder running "umount /home" (be careful, you must not be in this folder while running this command). At this point, I can create a new folder, change the permissions for the new folder created, and mount the remote filesystem. The steps
were:

```sh
$ sudo mkdir /home/projects 
$ sudo chown myuser:staff /home/projects 
$ sshfs mysecretuser@mysecrethost:/my/secret/folder /home/projects
```

Note: type yoursecretpassword

### Using automount

For use OSXFUSE on a Mac, we need to write a single line in the file /etc/auto_home, but, we need to prepare a few other items.

The automount system runs as a daemon without user interaction. This means that we need to create a shared key, which the daemon can use to connect to the server.

To create a shared key, run:

```sh
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/myuser/.ssh/id_rsa): /Users/myuser/.ssh/myserver_id_rsa
```

Note: the passphrase can be empty

Next we must copy the key to the server. To do that, we need to install the `ssh-copy-id` script:

```sh
$ brew install ssh-copy-id
```

Copy the key using the previously installed script:

```sh
$ ssh-copy-id -i ~/.ssh/myserver_id_rsa.pub myuser@myserver
```

Note: It will ask for the password

Then test if it is ok trying to connect to the server:

```sh
$ ssh -i ~/.ssh/myserver_id_rsa myuser@myserver
```

Note: It won't ask for the password!!!

At this point, we can manually mount sshfs like in the previous section, but using the shared key:

```sh
$ sshfs -o IdentityFile=~/.ssh/myserver_id_rsa myuser@myserver:/my/remote/folder /my/local/folder
```

However, if we want to automatically mount the remote folder, we still have work to do.

For use OSX fuse in the automount tools, we need to set the next kernel variable to `1`:

```
osxfuse.tunables.allow_other=1
```

It will be nice to set this variable in the `/etc/sysctl.conf` file, but the problem is that we can only set up this variable once the kernel module is loaded. Apple encourages programmers to use launchd, so, I started using it.

The solution is really simple, we only need to create these files into `/Library/Application Support/AmaralAutoMount` folder:

org.amaral-lab.automount.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.example.app</string>
        <key>ProgramArguments</key>
        <array>
            <string>/bin/sh</string>
            <string>/Library/Application Support/AmaralAutoMount/org.amaral-lab.automount.sh</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
    </dict>
</plist>
```

org.amaral-lab.automount.sh

```sh
#!/bin/sh
/Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
sysctl -w osxfuse.tunables.allow_other=1
```

The first file define how to run the second one that is a sh script.

Now, the next step is configure launchd to use this file. To do that, I suggest to create a soft link to the “plist” file:

```sh
$ cd /Library/LaunchDaemons
$ sudo ln -s "/Library/Application Support/AmaralAutoMount/org.amaral-lab.automount.plist" .
```

To run this script we can restart the computer (easy way) or run this command:

```sh
$ sudo launchctl load /Library/LaunchDaemons/org.amaral-lab.automount.plist
```

Finally, we have all the prerequisites to write this line at the end of /etc/auto_home:

```sh
projects -fstype=sshfs,allow_other,idmap=user,ro,IdentityFile=/Users/myuser/.ssh/myserver_id_rsa myuser@myserver:/home/projects
```

Now, run this command to tell the daemon that the configuration files are changed so we can use the folder:

```sh
$ sudo automount -vc
$ ls /home/projects
```

I hope these lines will be useful for you!


[inspiration]: http://amaral-lab.org/resources/guides/mounting-remote-folder-os-x-over-ssh-yosemite
