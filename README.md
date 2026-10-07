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
