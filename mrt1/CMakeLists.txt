cmake_minimum_required(VERSION 3.21)
project(MRT1 VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# ─── Force Android ABIs BEFORE find_package() ─────────────────
# Qt deployment reads QT_ANDROID_ABIS during find_package() and
# qt_add_executable(). Setting it here ensures .so files are
# packaged for armeabi-v7a (real head unit / ARM devices).
if(ANDROID)
    set(QT_ANDROID_ABIS "armeabi-v7a" CACHE STRING "Android ABIs to build" FORCE)
endif()

# ─── Qt6 discovery on Android ─────────────────────────────────
if(ANDROID AND DEFINED ENV{QT_ROOT_DIR})
    set(MRT1_QT_PREFIX "$ENV{QT_ROOT_DIR}")
    set(MRT1_QT_CMAKE "${MRT1_QT_PREFIX}/lib/cmake")
    set(Qt6_DIR "${MRT1_QT_CMAKE}/Qt6" CACHE PATH "" FORCE)

    # Register every installed Qt6*/CMake package directory explicitly
    # so find_package() can resolve Core/Gui/Qml/Quick and their deps.
    file(GLOB MRT1_QT_PACKAGE_CONFIGS
        "${MRT1_QT_CMAKE}/Qt6*/Qt6*Config.cmake")
    foreach(MRT1_QT_CONFIG IN LISTS MRT1_QT_PACKAGE_CONFIGS)
        get_filename_component(MRT1_QT_PACKAGE_DIR "${MRT1_QT_CONFIG}" DIRECTORY)
        get_filename_component(MRT1_QT_PACKAGE_NAME "${MRT1_QT_PACKAGE_DIR}" NAME)
        set("${MRT1_QT_PACKAGE_NAME}_DIR" "${MRT1_QT_PACKAGE_DIR}" CACHE PATH "" FORCE)
    endforeach()
endif()

# ─── Qt modules ───────────────────────────────────────────────
find_package(Qt6 CONFIG REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Multimedia
    Network
    Sql
    SerialPort
    Positioning
)

# ─── Executable ───────────────────────────────────────────────
qt_add_executable(MRT1
    src/main.cpp
    src/VehicleDataProvider.h
    src/VehicleDataBackend.h
    src/CanProvider.h
    src/ObdProvider.h
    src/SpeechManager.h
    src/AudioNoiseFilter.h
    src/FactoryDiagnostics.h
    src/HardwareProbe.h
    src/ReadOnlySerialProbe.h
    src/AutoMatchManager.h
    src/GpsSpeedProvider.h
    src/VehicleSpeedRouter.h
    src/OpenAIManager.h
    src/LocalDatabase.h
    src/SetupManager.h
    src/CanFrameMonitor.h
    src/CanSignalDecoder.h
    src/LocalMusicManager.h
    src/PhoneManager.h
    src/RestartManager.h
)

# ─── QML module ───────────────────────────────────────────────
qt_add_qml_module(MRT1
    URI MRT1
    VERSION 1.0
    NO_CACHEGEN
    QML_FILES
        qml/Main.qml
        qml/Dashboard.qml
        qml/LuxuryDashboard.qml
        qml/LuxuryMusic.qml
        qml/Vehicle.qml
        qml/Settings.qml
        qml/Diagnostics.qml
        qml/AutoMatch.qml
        qml/Jarvis.qml
        qml/JarvisSettings.qml
        qml/Navigation.qml
        qml/Music.qml
        qml/Phone.qml
        qml/OptionalModules.qml
        qml/CanCapture.qml
        qml/CanDecoder.qml
)

# ─── Link libraries ───────────────────────────────────────────
target_link_libraries(MRT1 PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Multimedia
    Qt6::Network
    Qt6::Sql
    Qt6::SerialPort
    Qt6::Positioning
)

# ─── Android target properties ────────────────────────────────
if(ANDROID)
    set_target_properties(MRT1 PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
        QT_ANDROID_MIN_SDK_VERSION 23
        QT_ANDROID_TARGET_SDK_VERSION 28
        QT_ANDROID_ABIS "armeabi-v7a"
    )
endif()
