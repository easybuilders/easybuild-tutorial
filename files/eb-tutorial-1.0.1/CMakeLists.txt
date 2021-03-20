cmake_minimum_required(VERSION 3.8)
project(eb-tutorial VERSION 1.0.1 LANGUAGES CXX)

set(EBTUTORIAL_MSG "" CACHE STRING "Message to print (a string)")

if(NOT EBTUTORIAL_MSG)
    message(FATAL_ERROR "EBTUTORIAL_MSG is not set!")
endif()

configure_file(eb-tutorial-message.hpp.in ebtutorial-message.hpp @ONLY)

add_executable(eb-tutorial main.cpp)
target_include_directories(eb-tutorial PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

install(TARGETS eb-tutorial RUNTIME DESTINATION bin)
