# Artix GNU/Linux Installer
The days of manually installing your favorite lightweight rolling release distro are over. This installer provides a safe and easy way to create a bootable installation in under 5 minutes. 
## The finished installation...

- uses GPT 
- uses Grub
- is installed on a BTRFS subvolume
- and uses Runit on Artix GNU/Linux

## Selecting the right installation type
The installation script provides 4 different installation types, select the right one for your personal needs.
| Number| Partitions | Advantages | Disadvantages |
|-|-|-|-|
| 1 (Default) | - unencrypted boot partiton<br> - unencrypted root partition                     | no password required         | all files readable if different OS is used                         |
| 2           | - unencrypted boot partiton<br> - encrypted root partition                       | all files encrypted          | an attacker can modify the kernel to extract the root Password |
| 3           | - unencrypted EFI partition<br> - encrypted boot + root partition                | all files + kernel encrypted | Grub's Luks encryption is really slow                          |
| 4           | - unencrypted EFI partition<br> - encrypted boot partiton<br> - encrypyed root partition | all files + kernel encrypted | Requires 2 passwords                                           |
## Usage
To get the scripts to your life environment you can use one of the following methods:
### 1. Download the repository
Download the installation medium and boot it; then download the latest release.
```sh
su
curl -OL https://github.com/Doge815/ArtixInstaller/archive/v1.0.tar.gz
tar -xzf v1.0.tar.gz
cd ArtixInstaller-1.0
```
### 2. Use [transfer.sh](https://transfer.sh/)
If you want a convenient way to use modified scripts without forking the reopository, use this method.
Firstly clone the repository on your PC (not inside the life environment of course).
```sh
git clone https://github.com/Doge815/ArtixInstaller.git
cd ArtixInstaller
```
Now is the perfect time to modify the scripts to your personal needs.
After you're done, run the upload script, which uploads the scripts to [transfer.sh](https://transfer.sh).
```sh
./upload.sh
```
The output should contain a link like this:
```sh
https://transfer.sh/xxxxxx/scripts.tar
```
Write the link down and boot up your life environment.
Now download the archive with your scripts and extract them.
```sh
su
curl -OL https://transfer.sh/xxxxxx/scripts.tar
tar -xf scripts.sh
```
### Modify the config file
If you haven't modified the config.sh file already, do it now. The installation script is NOT interactive and relies solely on the settings inside config.sh. Make sure you select the right target disk and installation Type.
### Run the scripts
No matter how you managed to get the scripts to the life environment, the next step is simple.
Just run the installer script, lean back, drink a cup of coffee and after a few minutes your Artix GNU/Linux installation is ready.
```sh
./base.sh
```
## WARNING
Even though the config file is shredded after the installation has finished, you should change the user and the root password as soon as possible. DO NOT KEEP THE PASSWORDS if you modified them before uploading the scripts with [transfer.sh](https://transfer.sh).
