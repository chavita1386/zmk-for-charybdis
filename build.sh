#!/bin/bash
# ZMK Build Script for Charybdis Keyboard

set -e

# Default values
BOARD=${BOARD:-nice_nano_v2}
SIDE=${SIDE:-left}
SHIELD=${SHIELD:-charybdis_left}

# Build directory
BUILD_DIR="/app/build/${SIDE}"

echo "Building ZMK firmware..."
echo "Board: ${BOARD}"
echo "Shield: ${SHIELD}"
echo "Side: ${SIDE}"
echo "Build directory: ${BUILD_DIR}"

# Clean build directory
rm -rf "${BUILD_DIR}"

# Build firmware
if [ "$SIDE" = "reset" ]; then
    echo "Building settings reset firmware..."
    cd /app/zmk/app
    west build -p -d "${BUILD_DIR}" -b "${BOARD}" -- -DSHIELD="${SHIELD}" -DZMK_CONFIG="/app/config"
    
    # Copy firmware file
    if [ -f "${BUILD_DIR}/zephyr/zmk.uf2" ]; then
        cp "${BUILD_DIR}/zephyr/zmk.uf2" "/app/firmware/${BOARD}-${SHIELD}.uf2"
        echo "Firmware saved to: firmware/${BOARD}-${SHIELD}.uf2"
    else
        echo "Error: Firmware file not found!"
        exit 1
    fi
else
    echo "Building keyboard firmware..."
    cd /app/zmk/app
    west build -p -d "${BUILD_DIR}" -b "${BOARD}" -- -DSHIELD="${SHIELD}" -DZMK_CONFIG="/app/config"
    
    # Copy firmware file
    if [ -f "${BUILD_DIR}/zephyr/zmk.uf2" ]; then
        cp "${BUILD_DIR}/zephyr/zmk.uf2" "/app/firmware/${BOARD}-${SHIELD}.uf2"
        echo "Firmware saved to: firmware/${BOARD}-${SHIELD}.uf2"
    else
        echo "Error: Firmware file not found!"
        exit 1
    fi
fi

# Show build completion
echo "Build completed successfully!"
echo "Output: firmware/${BOARD}-${SHIELD}.uf2"

# List firmware directory contents
echo "Firmware directory contents:"
ls -la /app/firmware/