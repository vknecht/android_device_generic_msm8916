include device/generic/msm8916/shared/BoardConfig.mk

# Board Information
TARGET_BOOTLOADER_BOARD_NAME := idol3
TARGET_BOARD_PLATFORM := idol3
TARGET_SCREEN_DENSITY := 400

# Kernel/boot.img Configuration
BOARD_KERNEL_CMDLINE     += androidboot.hardware=idol3

# Image Configuration
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 2874146816
BOARD_USERDATAIMAGE_PARTITION_SIZE := 12176530432
