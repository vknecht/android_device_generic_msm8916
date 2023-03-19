#
# Copyright (C) 2011 The Android Open-Source Project
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

PRODUCT_COPY_FILES := \
    $(LOCAL_PATH)/fstab.ramdisk:$(TARGET_COPY_OUT_RAMDISK)/fstab.kiwi \
    $(LOCAL_PATH)/fstab.ramdisk:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.kiwi \
    $(LOCAL_PATH)/etc/audio.kiwi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio.kiwi.xml \
    $(LOCAL_PATH)/etc/sensors.kiwi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/sensors.kiwi.rc \
    device/generic/msm8916/shared/init.msm8939.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.kiwi.rc \
    device/generic/msm8916/shared/init.msm8916.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.kiwi.usb.rc \
    device/generic/msm8916/shared/key_layout.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/kiwi.kl

# Build generic Audio HAL
PRODUCT_PACKAGES := audio.primary.kiwi

# Build generic lights HAL
PRODUCT_PACKAGES += lights.kiwi

# Create mountpoints and symlinks for firmware files
PRODUCT_PACKAGES += kiwi_firmware

