/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <array>
#include <fstream>

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/ioctl.h>
#include <sys/types.h>

#include <aidl/android/hardware/light/BnLights.h>
#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>

using ::aidl::android::hardware::light::BnLights;
using ::aidl::android::hardware::light::HwLight;
using ::aidl::android::hardware::light::HwLightState;
using ::aidl::android::hardware::light::ILights;
using ::aidl::android::hardware::light::LightType;
using ::aidl::android::hardware::light::FlashMode;
using ::ndk::ScopedAStatus;
using ::ndk::SharedRefBase;

static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

char const* const LED_FILE = "/sys/class/leds/led@1/brightness";
char const* const LED_FILE_TRG = "/sys/class/leds/led@1/trigger";
char const* const LED_FILE_ON = "/sys/class/leds/led@1/delay_on";
char const* const LED_FILE_OFF = "/sys/class/leds/led@1/delay_off";

char const* const LCD_FILE = "/sys/class/backlight/backlight/brightness";

static char const* const MAX_BRIGHTNESS_FILE = "/sys/class/backlight/backlight/max_brightness";

static int SYS_MAX_BRIGHTNESS = 0; // Max brightness read from system

static int sys_write_int(int fd, int value) {
    char buffer[16];
    size_t bytes;
    ssize_t amount;

    bytes = snprintf(buffer, sizeof(buffer), "%d\n", value);
    if (bytes >= sizeof(buffer)) return -EINVAL;
    amount = write(fd, buffer, bytes);
    return amount == -1 ? -errno : 0;
}

static int sysfs_read_int(const char* name, int& value) {
    uint8_t const BUFFER_SIZE = 16;
    char buffer[BUFFER_SIZE] = {0};
    ssize_t amount = -EINVAL;
    int fd = open(name, O_RDONLY);
    if (fd < 0) {
        LOG(ERROR) << "COULD NOT OPEN LED_DEVICE" << name;
        return amount;
    }
    do {
        amount = read(fd, (void *)buffer, BUFFER_SIZE);
        if (-EINVAL == amount) {
            break;
        }
        value = atoi(buffer);
    } while (false);
    close(fd);
    return amount;
}

class Lights : public BnLights {
  private:
    std::vector<HwLight> availableLights;

    void addLight(LightType const type, int const ordinal) {
        HwLight light{};
        light.id = availableLights.size();
        light.type = type;
        light.ordinal = ordinal;
        availableLights.emplace_back(light);
    }

    int rgbToBrightness(int color) {
        int const r = ((color >> 16) & 0xFF) * 77 / 255;
        int const g = ((color >> 8) & 0xFF) * 150 / 255;
        int const b = (color & 0xFF) * 29 / 255;
        return (r << 16) | (g << 8) | b;
    }

    void writeLed(const char* path, int color) {
        int fd = open(path, O_WRONLY);
        if (fd < 0) {
            LOG(ERROR) << "COULD NOT OPEN LED_DEVICE " << path;
            return;
        }

        sys_write_int(fd, color);
        close(fd);
    }

    int convertBrightness(int current_brightness) {
        uint32_t const MAX_BRIGHTNESS = 0xFF;   // Max brightness received from API
        uint32_t const MIN_BRIGHTNESS = 0x00;
        const int max_shift = MAX_BRIGHTNESS - MIN_BRIGHTNESS;
        int received_brightness_shift = max_shift - (MAX_BRIGHTNESS - (current_brightness & 0xFF));
        int received_brightness_percent = (received_brightness_shift * 100) / max_shift;
        int calculated = (SYS_MAX_BRIGHTNESS * received_brightness_percent) / 100;
        return calculated > SYS_MAX_BRIGHTNESS ? SYS_MAX_BRIGHTNESS : calculated;
    }

  public:
    Lights() : BnLights() {
        pthread_mutex_init(&g_lock, NULL);

        addLight(LightType::BACKLIGHT, 0);
        addLight(LightType::KEYBOARD, 0);
        addLight(LightType::BUTTONS, 0);
        addLight(LightType::BATTERY, 0);
        addLight(LightType::NOTIFICATIONS, 0);
        // Attention light might overwrite notifications
        //addLight(LightType::ATTENTION, 0);
        //addLight(LightType::BLUETOOTH, 0);
        //addLight(LightType::WIFI, 0);
    }

    ScopedAStatus setLightState(int id, const HwLightState& state) override {
        if (!(0 <= id && id < availableLights.size())) {
            LOG(ERROR) << "Light id " << (int32_t)id << " does not exist.";
            return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
        }

        int const color = rgbToBrightness(state.color);
        HwLight const& light = availableLights[id];

        int ret = 0;

        if (auto stream = std::ofstream(LED_FILE_TRG)) {
            switch (state.flashMode) {
		case FlashMode::HARDWARE:
		    LOG(ERROR) << "Hardware flashmode not yet supported, falling back to timed";
		    //return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
		    FALLTHROUGH_INTENDED;
		case FlashMode::TIMED:
		    stream << "timer";
                    break;
                case FlashMode::NONE:
                    stream << "none";
		    break;
            }
        } else {
            LOG(ERROR) << "Failed to write `trigger` to " << LED_FILE_TRG;
	    return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
	}

        switch (light.type) {
            case LightType::BATTERY:
		LOG(ERROR) << "battery rgb=" << std::hex << state.color << " rgbtob=" << color;
                writeLed(LED_FILE, color);
                break;
            case LightType::ATTENTION:
		LOG(ERROR) << "attention rgb=" << std::hex << state.color << " rgbtob=" << color;
                writeLed(LED_FILE, color);
                break;
	    case LightType::NOTIFICATIONS:
		LOG(ERROR) << "notifications rgb=" << std::hex << state.color << " rgbtob=" << color;
                writeLed(LED_FILE, color);
                break;
            case LightType::BACKLIGHT:
                writeLed(LCD_FILE, convertBrightness(state.color));
                break;
	    default:
		LOG(ERROR) << "Unhandled light type";
		break;
        }

	switch (state.flashMode) {
		case FlashMode::NONE:
			break;
		case FlashMode::HARDWARE:
		case FlashMode::TIMED:
			LOG(ERROR) << "flashmode timed on=" << state.flashOnMs << "ms and off=" << state.flashOffMs << "ms";
			if (auto stream = std::ofstream(LED_FILE_ON))
				stream << state.flashOnMs;
			if (auto stream = std::ofstream(LED_FILE_OFF))
				stream << state.flashOffMs;
			break;
	}

        if (ret == 0) {
            return ScopedAStatus::ok();
        } else {
            return ScopedAStatus::fromServiceSpecificError(ret);
        }
    }

    ScopedAStatus getLights(std::vector<HwLight>* lights) override {
        for (auto i = availableLights.begin(); i != availableLights.end(); i++) {
            lights->push_back(*i);
        }
        return ScopedAStatus::ok();
    }
};

int main() {
    ABinderProcess_setThreadPoolMaxThreadCount(0);

    std::shared_ptr<Lights> light = SharedRefBase::make<Lights>();

    const std::string instance = std::string() + ILights::descriptor + "/default";
    binder_status_t status = AServiceManager_addService(light->asBinder().get(), instance.c_str());

    if (status != STATUS_OK) {
        LOG(ERROR) << "Could not register" << instance;
        // should abort, but don't want crash loop for local testing
    }
    if (-EINVAL == sysfs_read_int(MAX_BRIGHTNESS_FILE, SYS_MAX_BRIGHTNESS)) {
        LOG(ERROR) << "COULD NOT OPEN LED_DEVICE" << MAX_BRIGHTNESS_FILE;
    }
    ABinderProcess_joinThreadPool();

    return 1;  // should not be reached
}
