cmake_minimum_required(VERSION 3.21)
project(MRT1 VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

if(ANDROID AND DEFINED ENV{QT_ROOT_DIR})
    set(MRT1_QT_PREFIX "$ENV{QT_ROOT_DIR}")
    set(MRT1_QT_CMAKE "${MRT1_QT_PREFIX}/lib/cmake")
    set(Qt6Core_DIR "${MRT1_QT_CMAKE}/Qt6Core" CACHE PATH "" FORCE)
    set(Qt6Gui_DIR "${MRT1_QT_CMAKE}/Qt6Gui" CACHE PATH "" FORCE)
    set(Qt6Qml_DIR "${MRT1_QT_CMAKE}/Qt6Qml" CACHE PATH "" FORCE)
    set(Qt6Quick_DIR "${MRT1_QT_CMAKE}/Qt6Quick" CACHE PATH "" FORCE)
    set(Qt6QuickControls2_DIR "${MRT1_QT_CMAKE}/Qt6QuickControls2" CACHE PATH "" FORCE)
    set(Qt6Multimedia_DIR "${MRT1_QT_CMAKE}/Qt6Multimedia" CACHE PATH "" FORCE)
    set(Qt6Network_DIR "${MRT1_QT_CMAKE}/Qt6Network" CACHE PATH "" FORCE)
    set(Qt6Sql_DIR "${MRT1_QT_CMAKE}/Qt6Sql" CACHE PATH "" FORCE)
    set(Qt6SerialPort_DIR "${MRT1_QT_CMAKE}/Qt6SerialPort" CACHE PATH "" FORCE)
    set(Qt6Positioning_DIR "${MRT1_QT_CMAKE}/Qt6Positioning" CACHE PATH "" FORCE)
endif()

find_package(Qt6Core CONFIG REQUIRED)
find_package(Qt6Gui CONFIG REQUIRED)
find_package(Qt6Qml CONFIG REQUIRED)
find_package(Qt6Quick CONFIG REQUIRED)
find_package(Qt6QuickControls2 CONFIG REQUIRED)
find_package(Qt6Multimedia CONFIG REQUIRED)
find_package(Qt6Network CONFIG REQUIRED)
find_package(Qt6Sql CONFIG REQUIRED)
find_package(Qt6SerialPort CONFIG REQUIRED)
find_package(Qt6Positioning CONFIG REQUIRED)

qt_add_executable(MRT1
 src/main.cpp src/VehicleDataProvider.h src/VehicleDataBackend.h
 src/CanProvider.h src/ObdProvider.h src/SpeechManager.h src/AudioNoiseFilter.h
 src/FactoryDiagnostics.h src/HardwareProbe.h src/ReadOnlySerialProbe.h
 src/AutoMatchManager.h src/GpsSpeedProvider.h src/VehicleSpeedRouter.h src/OpenAIManager.h src/LocalDatabase.h src/SetupManager.h
 src/CanFrameMonitor.h src/CanSignalDecoder.h src/LocalMusicManager.h src/PhoneManager.h)

qt_add_qml_module(MRT1 URI MRT1 VERSION 1.0
 QML_FILES
 qml/Main.qml
 qml/Dashboard.qml
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
 qml/CanDecoder.qml)

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
 Qt6::Positioning)

if(ANDROID)
    set_target_properties(MRT1 PROPERTIES
      QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
      QT_ANDROID_MIN_SDK_VERSION 28
      QT_ANDROID_TARGET_SDK_VERSION 33
      QT_ANDROID_ABIS "armeabi-v7a")
endif()
