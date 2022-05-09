tar -cf scripts.tar base.sh chroot.sh config.sh
curl --upload-file ./scripts.tar https://transfer.sh/
echo
rm scripts.tar