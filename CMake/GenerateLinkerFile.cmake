set(NRF51_BOOTLOADER_FLASH_SIZE "24576" CACHE STRING "Reserved flash for bootloader")
set(NRF51_BOOTLOADER_RAM_SIZE "768" CACHE STRING "Reserved RAM for bootloader")
set(NRF52_BOOTLOADER_FLASH_SIZE "32768" CACHE STRING "Reserved flash for bootloader")
set(NRF52_BOOTLOADER_RAM_SIZE "4096" CACHE STRING "Reserved RAM for bootloader")

set(GCC_LD_TEMPLATE_FILE ${CMAKE_CONFIG_DIR}/toolchain/templates/gcc.ld.in CACHE FILE "GCC template linker file")
set(ARMCC_LD_TEMPLATE_FILE ${CMAKE_CONFIG_DIR}/toolchain/templates/armcc.sct.in CACHE FILE "ARMCC template linker (scatter) file")

# Start of flash region in memory map (0x20000000)
set(RAM_ADDRESS_START "536870912")

function(to_hex DEC HEX)
    while(DEC GREATER 0)
        math(EXPR _val "${DEC} % 16")
        math(EXPR DEC "${DEC} / 16")
        if(_val EQUAL 10)
            set(_val "A")
        elseif(_val EQUAL 11)
            set(_val "B")
        elseif(_val EQUAL 12)
            set(_val "C")
        elseif(_val EQUAL 13)
            set(_val "D")
        elseif(_val EQUAL 14)
            set(_val "E")
        elseif(_val EQUAL 15)
            set(_val "F")
        endif()
        set(_res "${_val}${_res}")
    endwhile()
    set(${HEX} "0x${_res}" PARENT_SCOPE)
endfunction()

function (generate_linker_file OUTPUT_FILE ENABLE_BOOTLOADER)

    set(application_flash_start ${${SOFTDEVICE}_FLASH_SIZE})
    math(EXPR application_flash_size "${${PLATFORM}_FLASH_SIZE} - ${${SOFTDEVICE}_FLASH_SIZE}")
    math(EXPR application_ram_start "${RAM_ADDRESS_START} + ${${SOFTDEVICE}_RAM_SIZE}")
    math(EXPR application_ram_size "${${PLATFORM}_RAM_SIZE} - ${${SOFTDEVICE}_RAM_SIZE}")

    if (ENABLE_BOOTLOADER)
        math(EXPR application_flash_size "${application_flash_size} - ${${${PLATFORM}_FAMILY}_BOOTLOADER_FLASH_SIZE}")
        math(EXPR application_ram_size "${application_ram_size} - ${${${PLATFORM}_FAMILY}_BOOTLOADER_RAM_SIZE}")
    endif (ENABLE_BOOTLOADER)

    to_hex(${application_flash_start} application_flash_start)
    to_hex(${application_flash_size} application_flash_size)
    to_hex(${application_ram_start} application_ram_start)
    to_hex(${application_ram_size} application_ram_size)

    if (TOOLCHAIN MATCHES "gcc" OR TOOLCHAIN STREQUAL "clang")
        configure_file(${GCC_LD_TEMPLATE_FILE} ${OUTPUT_FILE})
    elseif (TOOLCHAIN STREQUAL "armcc")
        configure_file(${ARMCC_LD_TEMPLATE_FILE} ${OUTPUT_FILE})
    else ()
        message(FATAL_ERROR "Could not generate linker file for unknown toolchain \"${TOOLCHAIN}\".")
    endif ()
endfunction (generate_linker_file)
