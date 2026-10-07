# MRT1 Car Dashboard

MRT1 is a lightweight Android/QML automotive dashboard derived from the OCTAVE architecture.

Target hardware:
- Android 10
- ARM Cortex-A7 quad core ~1.3 GHz
- 2 GB RAM
- 1024x600 landscape
- minSdk 28
- package: com.mrt.jarvis

Core:
- Dashboard Engine
- Vehicle Data
- OBD/CAN architecture
- Music
- Phone
- Navigation
- JARVIS
- Settings
- Diagnostics
- Auto Scaling
- QML UI
- Volume
- Clock/Date
- Warnings
- Gauges
- Android

Optional/test modules retained for hardware testing:
- 3D Vehicle View
- Phone Mirroring / scrcpy
- Quick3D / Jeep 3D

Design rule: core operation is offline-first. Optional online services must never block startup.


## Safety / factory integration
MRT1 does not write CAN configuration, MCU firmware, factory EEPROM, reverse-camera coding, or 360-camera settings. Factory diagnostics and serial/CAN capture are read-only until the exact vendor protocol for this head unit is identified.

## CAN capture workflow
1. Open Settings → Diagnostics and run the read-only hardware probe.
2. Select a detected serial interface and baud rate.
3. Open Settings → CAN / MCU RAW CAPTURE.
4. Start capture and collect real RX frames.
5. Only after real frames are captured should vehicle-signal mapping be added.

No simulated vehicle values are used by the production data path.
