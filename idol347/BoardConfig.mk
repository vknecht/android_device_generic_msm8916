include device/generic/msm8916/shared/BoardConfig.mk

# Board Information
TARGET_BOOTLOADER_BOARD_NAME := idol347
TARGET_BOARD_PLATFORM := idol347
TARGET_SCREEN_DENSITY := 320

# Kernel/boot.img Configuration
BOARD_KERNEL_CMDLINE     += androidboot.hardware=idol347

# Image Configuration
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 1932736512
BOARD_USERDATAIMAGE_PARTITION_SIZE := 5257960448
