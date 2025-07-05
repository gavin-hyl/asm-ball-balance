# Assembly Ball Balance Game

A complete embedded gaming system implemented in AVR assembly language. This project creates an interactive ball balance game with tilt-based controls, LED visualization, and dynamic sound effects.

## Overview

The Ball Balance Game is an embedded gaming system that challenges players to balance a virtual ball on a tilting platform. Using an IMU (Inertial Measurement Unit) for motion detection, players physically tilt the game board to control the ball's movement while navigating through various game modes and difficulty settings. Please refer to the [functional specification](spec.pdf) for more details.

## Game Description

### Core Gameplay
- **Objective**: Keep the ball balanced within the safe zone on the LED array
- **Controls**: Tilt the physical game board to influence ball movement
- **Physics**: Realistic ball physics with gravity simulation and velocity mechanics
- **Challenge**: Avoid letting the ball fall off the edges or leave the safe zone

### Game Modes
- **Timed Mode**: Complete the challenge within a specified time limit
- **Infinite Mode**: Play continuously without time constraints
- **Difficulty Settings**: Adjustable gravity, boundary constraints, and random events

## System Architecture

### Hardware Platform
- **Microcontroller**: ATmega64 (AVR 8-bit RISC)
- **Clock**: System timer-based real-time operation
- **Memory**: 4KB SRAM, 64KB Flash program memory
- **I/O**: Multiple timer channels, SPI communication, GPIO controls

### Input Systems
- **IMU (MPU6500)**: 3-axis accelerometer for tilt detection
- **Switches**: Menu navigation and game control interface
- **Real-time Processing**: 10Hz position updates with fractional precision

### Output Systems
- **LED Array**: 70 LEDs displaying ball position and safe zones
- **7-Segment Display**: Game status, scores, settings, and menu display
- **Audio System**: Background music and sound effects through speaker
- **Visual Feedback**: Dynamic LED patterns and status indicators

## File Structure

### Core System Files
```
asm-ball-balance/
├── README.md              # This file
├── main.asm               # Main program loop and initialization
├── AvrBuild.bat           # Build script for AVR toolchain
└── spec.pdf               # Complete functional specification
```

### Game Logic Components
```
├── game.asm               # Core game mechanics and physics
├── gamedisplay.asm        # Game visualization and LED control
├── menu.asm               # Menu system and user interface
├── timer.asm              # Software timer management
└── random.asm             # Random number generation for events
```

### Hardware Interface Modules
```
├── imu.asm                # IMU communication and data processing
├── display.asm            # LED array and 7-segment display control
├── sound.asm              # Audio generation and sound effects
├── music.asm              # Background music and audio sequences
├── spi.asm                # SPI communication protocol
├── io.asm                 # General I/O port management
├── switch.asm             # Switch input handling and debouncing
└── chiptimer.asm          # Hardware timer configuration
```

### Utility and Support Files
```
├── div.asm                # Division and mathematical operations
├── shift16.asm            # 16-bit shift operations
├── segtable.asm           # 7-segment display character encoding
└── *.inc                  # Definition files and constants
```

## Technical Features

### Real-Time Processing
- **10Hz Game Loop**: Smooth ball movement with fractional position tracking
- **Interrupt-Driven**: Timer-based system for precise timing control
- **Multi-tasking**: Concurrent game logic, display updates, and input processing

### Advanced Physics Engine
- **Gravity Simulation**: Configurable gravitational acceleration
- **Velocity Tracking**: Integer and fractional velocity components
- **Collision Detection**: Boundary checking and safe zone management
- **Smooth Movement**: Sub-pixel positioning for fluid ball motion

### Communication Protocols
- **SPI Interface**: High-speed communication with IMU sensor
- **Sensor Fusion**: 3-axis accelerometer data processing
- **Noise Filtering**: Signal processing for stable tilt detection

### Audio System
- **Dynamic Music**: Background music with looping capabilities
- **Sound Effects**: Event-triggered audio feedback
- **Volume Control**: Adjustable audio output levels
- **Multi-channel**: Concurrent music and sound effect playback

## User Interface

### Menu System
- **Settings Configuration**: Gravity, boundaries, time limits, ball size
- **Game Mode Selection**: Timed vs. infinite gameplay
- **Visual Feedback**: Clear 7-segment display messages
- **Intuitive Navigation**: Switch-based menu traversal

### Game Display
- **Ball Position**: Real-time LED visualization of ball location
- **Safe Zone**: Visual indicators for valid play area
- **Status Information**: Score, time, and game state display
- **Dynamic Updates**: Smooth LED transitions and animations

## Educational Context

This project provides comprehensive hands-on experience with:

### Embedded Systems Programming
- **Assembly Language**: Complete AVR assembly implementation
- **Register Management**: Efficient use of microcontroller resources
- **Memory Organization**: Code, data, and stack memory management
- **System Integration**: Hardware-software interface design

### Real-Time Systems
- **Timer Management**: Precise timing for game mechanics
- **Interrupt Handling**: Responsive system behavior
- **Task Scheduling**: Concurrent process management
- **Performance Optimization**: Efficient real-time processing

### Sensor Integration
- **IMU Communication**: SPI protocol implementation
- **Signal Processing**: Accelerometer data interpretation
- **Calibration**: Sensor offset and scaling management
- **Noise Reduction**: Filtering techniques for stable readings

### Human-Computer Interaction
- **Physical Interface**: Tilt-based control system
- **Visual Design**: LED array pattern design
- **Audio Feedback**: Sound system integration
- **User Experience**: Intuitive gameplay mechanics

## Development Features

### Code Organization
- **Modular Design**: Separate files for distinct functionalities
- **Comprehensive Documentation**: Detailed function headers and comments
- **Version Control**: Git repository with complete revision history
- **Build System**: Automated compilation and deployment

### Testing and Validation
- **Hardware Testing**: Complete system integration validation
- **Performance Analysis**: Real-time processing verification
- **User Testing**: Gameplay balance and difficulty tuning
- **Error Handling**: Robust system behavior under various conditions

## Game Instructions

1. **Power On**: System initializes and displays main menu
2. **Menu Navigation**: Use switches to select game mode and settings
3. **Start Game**: Press start button to begin gameplay
4. **Control Ball**: Tilt the board to move the ball left and right
5. **Objective**: Keep the ball within the safe zone boundaries
6. **Win Condition**: Survive the time limit (timed mode) or achieve high score
7. **Game Over**: Ball leaves safe zone or time expires

---

*This project represents a complete embedded systems implementation, demonstrating the integration of hardware interfaces, real-time processing, game physics, and user interaction in a sophisticated gaming platform.*
