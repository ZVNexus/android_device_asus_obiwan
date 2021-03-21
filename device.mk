# Copyright (C) 2021 Paranoid Android
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# APEX
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Boot
PRODUCT_PACKAGES += \
    android.hardware.boot@1.1-impl-qti \
    android.hardware.boot@1.1-impl-qti.recovery \
    android.hardware.boot@1.1-service

# Data
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.vendor.data.mode=concurrent \
    ro.vendor.use_data_netmgrd=true

# CNE
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.vendor.cne.feature=1

# Charging
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.charger.enable_suspend=1

# Fastboot
PRODUCT_PACKAGES += \
    fastbootd

# GSI
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Init
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init/fstab.qcom:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom

PRODUCT_PACKAGES += \
    fstab.qcom \
    init.qti.dcvs.sh \
    init.qti.ufs.rc \
    init.target.rc

# Media
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    media.settings.xml=/vendor/etc/media_profiles_vendor.xml \
    media.stagefright.thumbnail.prefer_hw_codecs=true \
    ro.media.recorder-max-base-layer-fps=60

# Namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Overlays
PRODUCT_PACKAGES += \
    FrameworksResTarget \
    WifiResTarget

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Platform
TARGET_BOARD_PLATFORM := kona

# QTI
TARGET_COMMON_QTI_COMPONENTS := all

# Sensors
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.vendor.sensors.enable.mag_filter=true

# Shipping API
PRODUCT_SHIPPING_API_LEVEL := 29

# Telephony
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    DEVICE_PROVISIONED=1 \
    ril.subscription.types=NV,RUIM \
    ro.telephony.default_network=33,33 \
    telephony.lteOnCdmaDevice=1

# Treble
PRODUCT_FULL_TREBLE_OVERRIDE := true

# Update Engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# Vendor
$(call inherit-product, vendor/asus/obiwan/obiwan-vendor.mk)
