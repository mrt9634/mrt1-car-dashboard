cmake_minimum_required(VERSION 3.21)
project(MRT1 VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Multimedia Network)
qt_add_executable(MRT1
    src/main.cpp
    src/VehicleDataProvider.h
    src/LocalDatabase.h
    src/SetupManager.h
)
qt_add_qml_module(MRT1
    URI MRT1
    VERSION 1.0
    QML_FILES qml/Main.qml qml/Dashboard.qml qml/Vehicle.qml qml/Settings.qml
)
target_link_libraries(MRT1 PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Multimedia Qt6::Network)
if(ANDROID)
    set_target_properties(MRT1 PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
        QT_ANDROID_MIN_SDK_VERSION 28
        QT_ANDROID_TARGET_SDK_VERSION 33
        QT_ANDROID_ABIS "armeabi-v7a"
    )
endif()
