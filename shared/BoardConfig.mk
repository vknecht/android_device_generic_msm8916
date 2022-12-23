# Copyright (C) 2013 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Primary Arch
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_ABI := arm64-v8a

# Secondary Arch
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_VARIANT := cortex-a53
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi

TARGET_USES_64_BIT_BINDER := true

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false
TARGET_NO_RECOVERY := true

# Kernel/boot.img Configuration
BOARD_KERNEL_BASE         := 0x80000000
BOARD_KERNEL_PAGESIZE     := 2048
BOARD_KERNEL_TAGS_OFFSET  := 0x01e00000
BOARD_RAMDISK_OFFSET      := 0x02000000
#BOARD_KERNEL_CMDLINE      := console=ttyMSM0,115200n8 earlycon earlyprintk console=tty0 androidboot.console=ttyMSM0 # console=tty0 causes uart to stop ?
BOARD_KERNEL_CMDLINE      := console=tty0 androidboot.console=tty0 no_console_suspend
BOARD_KERNEL_CMDLINE      += androidboot.boot_devices=soc@0/7824900.mmc
BOARD_KERNEL_CMDLINE      += androidboot.selinux=permissive
BOARD_KERNEL_CMDLINE      += firmware_class.path=/vendor/firmware/ init=/init printk.devkmsg=on
### 30 seconds might be too short here, and sometimes cause reboot
BOARD_KERNEL_CMDLINE      += deferred_probe_timeout=60
#BOARD_KERNEL_CMDLINE      += log_buf_len=15M audit_backlog_limit=8192 drm.debug=0x1f

# Image Configuration
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE     := 32000000 # keep some place for lk2nd #33554432 #32M
BOARD_VENDORIMAGE_PARTITION_SIZE   := 250000000 # ~256M

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

# Enable Treble
PRODUCT_FULL_TREBLE := true
BOARD_VNDK_VERSION := current

# Mesa DRM hwcomposer
BOARD_MESA3D_BUILD_LIBGBM := true
BOARD_USES_DRM_HWCOMPOSER := true
BOARD_MESA3D_USES_MESON_BUILD := true
BOARD_GPU_DRIVERS := freedreno virgl
BOARD_MESA3D_GALLIUM_DRIVERS := freedreno
BOARD_MESA3D_VULKAN_DRIVERS := freedreno
TARGET_USES_HWC2 := true

# WiFi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# BT
BOARD_HAVE_BLUETOOTH := true

# TinyHAL
BOARD_USES_TINYHAL_AUDIO := true

BOARD_SEPOLICY_DIRS += \
    device/generic/msm8916/shared/sepolicy \
    system/bt/vendor_libs/linux/sepolicy

# New BT fix : https://android-review.googlesource.com/c/device/linaro/dragonboard/+/2103025/
TARGET_PRODUCT_PROP := device/generic/msm8916/shared/product.prop

DEVICE_MANIFEST_FILE := device/generic/msm8916/shared/manifest.xml
DEVICE_MATRIX_FILE := device/generic/msm8916/shared/compatibility_matrix.xml

# Enable dex pre-opt to speed up initial boot
ifeq ($(HOST_OS),linux)
  ifeq ($(WITH_DEXPREOPT),)
    WITH_DEXPREOPT := true
    WITH_DEXPREOPT_PIC := true
  endif
endif
