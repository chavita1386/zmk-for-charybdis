# ZMK Build Environment for Charybdis Keyboard
FROM docker.io/zmkfirmware/zmk-build-arm:stable

# Set working directory
WORKDIR /app

# Copy West configuration
COPY config/west.yml config/west.yml

# Initialize West workspace and update dependencies
RUN west init -l config
RUN west update

# Export Zephyr SDK
RUN west zephyr-export

# Copy build script
COPY build.sh /app/build.sh
RUN chmod +x /app/build.sh

# Set default command
CMD ["/app/build.sh"]