ifneq ($(filter idol3 idol347, $(TARGET_DEVICE)),)

IMAGE_GZ := device/generic/msm8916/shared/prebuilt-kernel/android-$(TARGET_KERNEL_USE)/Image.gz
DTB := $(wildcard device/generic/msm8916/shared/prebuilt-kernel/android-$(TARGET_KERNEL_USE)/*-$(TARGET_DEVICE).dtb)

$(PRODUCT_OUT)/kernel: $(IMAGE_GZ) $(DTB)
	cat $(IMAGE_GZ) $(DTB) > $@

droidcore: $(PRODUCT_OUT)/kernel

endif
