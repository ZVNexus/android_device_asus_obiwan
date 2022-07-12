/*
 * Copyright (C) 2022 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>

#include <fcntl.h>
#include <poll.h>

#include <thread>
#include <vector>

#define PORT0_STATE_PATH "/sys/class/udc/a800000.dwc3/state"
#define PORT1_STATE_PATH "/sys/class/udc/a600000.dwc3/state"
#define CONFIGURED_STATE "configured"
#define NOT_ATTACHED_STATE "not attached"
#define STATE_MAX_LEN 256

bool readState(int fd, char* str) {
    unsigned int i = 0;
    int rc;

    rc = lseek(fd, 0, SEEK_SET);
    if (rc) {
        LOG(ERROR) << "failed to seek fd, err: %d";
        return false;
    }

    while (true) {
        char c;

        rc = read(fd, &c, sizeof(c));
        if (rc != 1) {
            LOG(ERROR) << "failed to read char from fd, err: %d";
            return false;
        }

        if (i >= STATE_MAX_LEN) {
            LOG(ERROR) << "state length exceeds max length";
            return false;
        }

        if (c == '\n') break;

        str[i++] = c;
    }

    str[i] = '\0';

    return true;
}

using android::base::ReadFileToString;
using android::base::SetProperty;

int main() {
    LOG(INFO) << "Started";

    char port0_state[STATE_MAX_LEN];
    char port1_state[STATE_MAX_LEN];

    std::vector<std::thread> threads;
    threads.emplace_back(std::thread([&port0_state]() {
        int fd = open(PORT0_STATE_PATH, O_RDONLY);
        if (fd < 0) {
            LOG(ERROR) << "failed to open fd, err: " << fd;
            return;
        }

        struct pollfd port0Poll = {
            .fd = fd,
            .events = POLLERR | POLLPRI,
            .revents = 0,
        };

        while (true) {
            int rc = poll(&port0Poll, 1, -1);
            if (rc < 0) {
                LOG(ERROR) << "failed to poll fd, err: " << rc;
                continue;
            }

            readState(fd, port0_state);
            LOG(INFO) << "BOTTOM USB CHANGED " << port0_state;

            if (!strcmp(port0_state, CONFIGURED_STATE)) {
                SetProperty("sys.usb.controller", "a800000.dwc3");
            } else if (!strcmp(port0_state, NOT_ATTACHED_STATE)
                    && !strcmp(port1_state, CONFIGURED_STATE)) {
                SetProperty("sys.usb.controller", "a600000.dwc3");
            }
        }
    }));
    threads.emplace_back(std::thread([&port1_state]() {
        int fd = open(PORT1_STATE_PATH, O_RDONLY);
        if (fd < 0) {
            LOG(ERROR) << "failed to open fd, err: " << fd;
            return;
        }

        struct pollfd port1Poll = {
            .fd = fd,
            .events = POLLERR | POLLPRI,
            .revents = 0,
        };

        while (true) {
            int rc = poll(&port1Poll, 1, -1);
            if (rc < 0) {
                LOG(ERROR) << "failed to poll fd, err: " << rc;
                continue;
            }

            readState(fd, port1_state);
            LOG(INFO) << "SIDE USB CHANGED " << port1_state;

            if (!strcmp(port1_state, CONFIGURED_STATE)) {
                SetProperty("sys.usb.controller", "a600000.dwc3");
            } else if (!strcmp(port1_state, NOT_ATTACHED_STATE)
                    && !strcmp(port0_state, CONFIGURED_STATE)) {
                SetProperty("sys.usb.controller", "a800000.dwc3");
            }
        }
    }));

    for (auto &thread : threads) thread.detach();
    for (auto &thread : threads) thread.join();

    return 0;
}
