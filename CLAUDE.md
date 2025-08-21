# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a ZMK firmware configuration for the Charybdis 4x6 split ergonomic keyboard with an integrated trackball. The Charybdis is a wireless split keyboard that uses the ZMK (Zephyr Mechanical Keyboard) firmware framework and connects via Bluetooth.

## Repository Structure

### Core Configuration Files
- `config/charybdis.keymap` - Main keymap configuration with layer definitions, behaviors, and key bindings
- `config/west.yml` - West manifest defining ZMK dependencies and external modules (PMW3610 trackball driver)
- `build.yaml` - GitHub Actions build matrix specifying board/shield combinations

### Hardware Definition (Shield)
- `config/boards/shields/charybdis/` - Complete shield definition for the Charybdis keyboard
  - `charybdis.dtsi` - Common device tree definitions (matrix transform, kscan, GPIO mappings)
  - `charybdis_left.overlay` - Left half specific GPIO configuration
  - `charybdis_right.overlay` - Right half with trackball SPI configuration and PMW3610 driver
  - `Kconfig.shield` - Shield detection and configuration options
  - `Kconfig.defconfig` - Default configuration for split keyboard setup
  - `charybdis.zmk.yml` - Shield metadata (features: keys, pointer, underglow)

## Building and Development

### Automated Building
This repository is configured for GitHub Actions automated builds:
- Push changes to trigger automatic firmware compilation
- Artifacts are generated for `nice_nano_v2` + `charybdis_left/right` combinations
- `settings_reset` firmware is also built for factory resets

### Manual Local Development
For local ZMK development, you would typically:
1. Set up ZMK development environment with West
2. Use `west build` commands targeting the specific shield configurations
3. Flash firmware to controllers via bootloader mode

### Testing Changes
- Use a `settings_reset` firmware first when making significant changes
- Test both left and right halves independently
- Verify Bluetooth pairing and split communication
- Test trackball functionality on right half

## Architecture and Key Components

### Hardware Architecture
- **Split Design**: Two halves communicate via Bluetooth (left is peripheral, right is central)
- **Trackball Integration**: PMW3610 sensor on right half connected via SPI
- **Controller**: Nice!Nano v2 (nRF52840-based) for wireless operation
- **Matrix**: 5x12 matrix (5 rows, 6 columns per half) with standard diode scanning

### Keymap Structure
The keymap defines 5 active layers:
- **Layer 0 (default)**: Base QWERTY layout with home row modifiers
- **Layer 1 (config)**: Bluetooth management and basic navigation
- **Layer 2 (numpad)**: Numeric keypad layout
- **Layer 3 (window_manager)**: Symbol layer with window management shortcuts
- **Layer 4 (vim)**: Vim-style navigation and media controls

### Custom Behaviors
Several specialized hold-tap behaviors are implemented:
- `pinky_layer`: Fast layer access via pinky fingers (120ms tapping term)
- `homemode`: Home row layer activation (150ms)
- `hrmode`: Home row modifiers for Shift, Ctrl, GUI, Alt
- `pinky_kp`: Pinky-specific key press behavior (140ms)

### Trackball Configuration
- **Driver**: PMW3610 via external `zmk-pmw3610-driver` module
- **Layer-Specific Behavior**: Currently configured for scroll mode on vim layer (layer 4)
- **GPIO**: CS on P0.20, IRQ on P0.06, SPI on SCK P0.08, MOSI/MISO P0.17
- **Input Listener**: Configured to process trackball events

#### Layer-Specific Trackball Settings
The trackball behavior can be customized per layer using these properties in `charybdis_right.overlay`:
- **scroll-layers**: Layers where trackball movement becomes scrolling (currently layer 4 - vim)
- **snipe-layers**: Layers with reduced sensitivity for precision movement (commented out)
- **automouse-layer**: Layer that auto-activates when trackball moves (commented out)

**Current Configuration**: `scroll-layers = <4>;` enables vertical/horizontal scrolling only on the vim layer. On all other layers, the trackball functions as normal mouse movement.

## Common Modifications

### Keymap Changes
- Edit `config/charybdis.keymap` to modify key assignments
- Use ZMK behavior syntax: `&kp`, `&mt`, `&lt`, custom behaviors
- Layer numbers correspond to array indices in keymap definition

### Hardware Modifications
- GPIO changes require updates to both `.dtsi` and `.overlay` files
- Trackball settings can be adjusted in `charybdis_right.overlay`
- Matrix modifications need updates to `default_transform` mapping

### Adding Features
- Additional behaviors go in the `behaviors` section of keymap
- New features may require Kconfig updates in shield definition
- External modules are managed via `west.yml` manifest

## Layer System

The keyboard uses a sophisticated layer system with multiple access methods:
- **Momentary layers**: `&mo` for temporary access while held
- **Layer taps**: `&lt` for hold-to-activate, tap-to-type
- **Toggle layers**: `&tog` for persistent layer switching
- **Home row integration**: Layer access integrated with home row modifiers

## Bluetooth and Connectivity

- **Pairing**: Layer 1 provides BT_SEL 0-4 for device selection
- **Management**: BT_CLR and BT_CLR_ALL for connection reset
- **Split Protocol**: ZMK handles split communication automatically
- **Power Management**: Automatic sleep/wake via ZMK power management

## Trackball Integration

The trackball is configured as a pointer device with:
- Automatic mouse movement translation
- Configurable scroll layers (currently layer 1)
- Support for click actions via mouse key bindings (`&mkp`)
- Sensor configuration optimized for PMW3610 optical sensor