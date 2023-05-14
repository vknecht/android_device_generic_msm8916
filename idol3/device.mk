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
    $(LOCAL_PATH)/fstab.ramdisk:$(TARGET_COPY_OUT_RAMDISK)/fstab.idol3 \
    $(LOCAL_PATH)/fstab.ramdisk:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.idol3 \
    $(LOCAL_PATH)/etc/audio.idol3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio.idol3.xml \
    $(LOCAL_PATH)/etc/sensors.idol3.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/sensors.idol3.rc \
    device/generic/msm8916/shared/init.msm8939.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.idol3.rc \
    device/generic/msm8916/shared/init.msm8916.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.idol3.usb.rc \
    device/generic/msm8916/shared/key_layout.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/idol3.kl

# Build generic Audio HAL
PRODUCT_PACKAGES := audio.primary.idol3

# Create mountpoints and symlinks for firmware files
PRODUCT_PACKAGES += idol3_firmware

