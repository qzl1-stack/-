cmake_minimum_required(VERSION 3.16)

project(Log_analyzer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appLog_analyzer
    main.cpp
    textfilehandler.cpp
    textfilehandler.h
)

qt_add_qml_module(appLog_analyzer
    URI Log_analyzer
    VERSION 1.0
    QML_FILES
        Main.qml
)

qt_add_resources(appLog_analyzer "qml"
    PREFIX "/"
    FILES
        Main.qml
)

set_target_properties(appLog_analyzer PROPERTIES
    AUTOMOC ON
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appLog_analyzer
    PRIVATE Qt6::Quick Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appLog_analyzer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
