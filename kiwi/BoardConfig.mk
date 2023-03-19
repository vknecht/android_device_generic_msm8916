include device/generic/msm8916/shared/BoardConfig.mk

# Board Information
TARGET_BOOTLOADER_BOARD_NAME := kiwi
TARGET_BOARD_PLATFORM := kiwi
TARGET_SCREEN_DENSITY := 400

# Kernel/boot.img Configuration
BOARD_KERNEL_CMDLINE     += androidboot.hardware=kiwi

# Image Configuration
BOARD_BOOTIMAGE_PARTITION_SIZE     := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 2684354560
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11618204672
