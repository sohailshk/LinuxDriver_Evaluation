#!/bin/bash
# create_mock_device.sh - Create mock device for WSL2 testing

DEVICE_NAME="hello_world"
DEVICE_PATH="/dev/${DEVICE_NAME}"

# Create mock device node if it doesn't exist
if [ ! -e "$DEVICE_PATH" ]; then
    echo "Creating mock device node: $DEVICE_PATH"
    sudo mknod "$DEVICE_PATH" c 240 0
    sudo chmod 666 "$DEVICE_PATH"
    echo "Mock device created successfully"
else
    echo "Device $DEVICE_PATH already exists"
fi

# Write some test data to the device
echo "Hello from kernel space!" | sudo tee "$DEVICE_PATH" > /dev/null
echo "Mock device initialized with test data"
