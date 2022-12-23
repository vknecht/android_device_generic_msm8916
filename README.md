# device/generic/msm8916 (AOSP device config for MSM8916 devices)

This device repo aims to support booting AOSP on MSM8916 devices supported by the mainline Linux kernel.

## Supported devices

* Alcatel Idol 3 4.7" (idol347)

# How to build and flash AOSP images?

* Download source and build AOSP images

```bash
mkdir aosp-repo
cd aosp-repo
repo init -u https://android.googlesource.com/platform/manifest -b master
git clone https://github.com/aospm/android_local_manifests .repo/local_manifests -b main
repo sync -j$nproc
source build/envsetup.sh
# See table above
lunch <codename>-userdebug # Where <codename> is the codename of your device
make -j$nproc
```

* Flash and boot AOSP images -->

```
fastboot flash system system.img
fastboot flash userdata userdata.img
fastboot flash cache vendor.img
fastboot flash boot boot.img
fastboot reboot
```
