#
# Copyright (C) 2023 The Android Open Source Project
# Copyright (C) 2023 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from 2120 device
$(call inherit-product, device/vivo/2120/device.mk)

PRODUCT_DEVICE := 2120
PRODUCT_NAME := omni_2120
PRODUCT_BRAND := vivo
PRODUCT_MODEL := V2134
PRODUCT_MANUFACTURER := vivo

PRODUCT_GMS_CLIENTID_BASE := android-vivo

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="full_k65v1_64_bsp-user 12 SP1A.210812.003 compiler04262006 release-keys"

BUILD_FINGERPRINT := vivo/2134T/2120:12/SP1A.210812.003/compiler04262006:user/release-keys
