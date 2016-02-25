IF(NOT STM32Cube_DIR)
    SET(STM32Cube_DIR "/opt/STM32Cube_FW_F1_V1.2.0")
    MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
ENDIF()

set(FreeRTOS_ROOT "${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS")

IF(STM32_FAMILY STREQUAL "F1")
    set(FreeRTOS_INCLUDE_DIRS "${FreeRTOS_ROOT}/Source/portable/GCC/ARM_CM3")
elseif(STM32_FAMILY STREQUAL "F4")
    set(FreeRTOS_INCLUDE_DIRS "${FreeRTOS_ROOT}/Source/portable/GCC/ARM_CM4F")
else()
    message(FATAL_ERROR "CPU not supported.")
endif()
list(APPEND FreeRTOS_INCLUDE_DIRS "${FreeRTOS_ROOT}/Source/include")
list(APPEND FreeRTOS_INCLUDE_DIRS "${FreeRTOS_ROOT}/Source/cmsis")

if(SUPPORT_RTOS_NO_CMSIS)
  add_definitions(-DSUPPORT_RTOS_NO_CMSIS)
else()
  add_definitions(-D__CMSIS_RTOS)
endif()

# Generate Configuration header file
#configure_file(include/FreeRTOSConfig.h.in ${CMAKE_CURRENT_BINARY_DIR}/FreeRTOSConfig.h)

set(FreeRTOS_COMMON_SRCS event_groups.c
                  list.c
                  queue.c
                  tasks.c
                  timers.c)

FOREACH(SRC ${FreeRTOS_COMMON_SRCS})
    SET(SRC_FILE SRC_FILE-NOTFOUND)
    FIND_FILE(SRC_FILE ${SRC}
        HINTS ${FreeRTOS_ROOT}/Source/
        CMAKE_FIND_ROOT_PATH_BOTH
    )
LIST(APPEND FreeRTOS_SOURCES ${SRC_FILE})
ENDFOREACH()

list(APPEND FreeRTOS_SOURCES "${FreeRTOS_ROOT}/Source/portable/MemMang/heap_4.c")

IF(STM32_FAMILY STREQUAL "F1")
    list(APPEND FreeRTOS_SOURCES "${FreeRTOS_ROOT}/Source/portable/GCC/ARM_CM0/port.c")
elseif(STM32_FAMILY STREQUAL "F4")
    list(APPEND FreeRTOS_SOURCES "${FreeRTOS_ROOT}/Source/portable/GCC/ARM_CM4F/port.c")
else()
    message(FATAL_ERROR "CPU not supported.")
endif()

if (NOT DEFINED SUPPORT_RTOS_NO_CMSIS)
    list(APPEND FreeRTOS_SOURCES "${FreeRTOS_ROOT}/Source/CMSIS_RTOS/cmsis_os.c")
endif()

#message(STATUS "FreeRTOS include ${FreeRTOS_INCLUDE_DIRS}")
#message(STATUS "FreeRTOS sources ${FreeRTOS_SOURCES}")

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(FreeRTOS DEFAULT_MSG FreeRTOS_INCLUDE_DIRS FreeRTOS_SOURCES)
