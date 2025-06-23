cmake_minimum_required(VERSION 3.16)
project(DualSenseDbusPlugin LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core DBus Qml)

# QML module URI and version
set(QML_IMPORT_NAME org.kde.dualsense)
set(QML_IMPORT_VERSION 1.1)

# 📦 Output location inside the plasmoid package
set(PLASMOID_PATH "${CMAKE_SOURCE_DIR}/../contents/code")
set(QML_BUILD_DIR "${CMAKE_BINARY_DIR}/${QML_IMPORT_NAME}")
set(QML_INSTALL_DIR "${PLASMOID_PATH}/${QML_IMPORT_NAME}")

# Tell CMake not to treat INSTALL_DIRECTORY as a system path
qt_policy(SET QTP0001 NEW)

qt_add_qml_module(dualsense
    URI ${QML_IMPORT_NAME}
    VERSION ${QML_IMPORT_VERSION}
    PLUGIN_TARGET dualsense
    OUTPUT_DIRECTORY ${QML_IMPORT_NAME}  # local to build dir
    SOURCES
        DbusBridge.cpp
        DbusBridge.h
)

target_link_libraries(dualsense
    PRIVATE Qt6::Core Qt6::Qml Qt6::DBus
)

# 🛠 Install directly into the plasmoid folder
install(TARGETS dualsense
    LIBRARY DESTINATION ${QML_INSTALL_DIR}
)

install(FILES
    ${QML_BUILD_DIR}/qmldir
    ${QML_BUILD_DIR}/dualsense.qmltypes
    DESTINATION ${QML_INSTALL_DIR}
)

# (Optional) kde-qmlmodule.version
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/kde-qmlmodule.version.in
    ${CMAKE_CURRENT_BINARY_DIR}/kde-qmlmodule.version
    @ONLY
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/kde-qmlmodule.version
    DESTINATION ${QML_INSTALL_DIR}
)
