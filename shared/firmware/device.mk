# Install firmware files

# Adreno
PRODUCT_PACKAGES :=	\
    a300_pfp.fw		\
    a300_pm4.fw

# Venus
# Video encoder/decoder accelerator
PRODUCT_PACKAGES +=	\
    venus.b00		\
    venus.b01		\
    venus.b02		\
    venus.b03		\
    venus.b04		\
    venus.mdt

# License
# Necessary to bundle license with firmware files
PRODUCT_PACKAGES +=	\
    LICENSE.qcom	\
    NOTICE.txt

PRODUCT_COPY_FILES := \
    $(LOCAL_PATH)/a300_pfp.fw:$(TARGET_COPY_OUT_VENDOR)/firmware/a300_pfp.fw \
    $(LOCAL_PATH)/a300_pm4.fw:$(TARGET_COPY_OUT_VENDOR)/firmware/a300_pm4.fw \
    $(LOCAL_PATH)/venus.b00:$(TARGET_COPY_OUT_VENDOR)/firmware/qcom/venus-1.8/venus.b00 \
    $(LOCAL_PATH)/venus.b01:$(TARGET_COPY_OUT_VENDOR)/firmware/qcom/venus-1.8/venus.b01 \
    $(LOCAL_PATH)/venus.b02:$(TARGET_COPY_OUT_VENDOR)/firmware/qcom/venus-1.8/venus.b02 \
    $(LOCAL_PATH)/venus.b03:$(TARGET_COPY_OUT_VENDOR)/firmware/qcom/venus-1.8/venus.b03 \
    $(LOCAL_PATH)/venus.b04:$(TARGET_COPY_OUT_VENDOR)/firmware/qcom/venus-1.8/venus.b04 \
    $(LOCAL_PATH)/venus.mdt:$(TARGET_COPY_OUT_VENDOR)/firmware/qcom/venus-1.8/venus.mdt
