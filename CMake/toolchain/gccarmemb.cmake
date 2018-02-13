set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(data_flags "-ffunction-sections -fdata-sections -fno-strict-aliasing -fno-builtin --short-enums")
set(warning_flags "-Wall -Wno-attributes -Wno-format")
set(CMAKE_C_FLAGS_INIT "--std=gnu99 ${warning_flags} ${data_flags}")
set(CMAKE_C_FLAGS_DEBUG "-Og -g3" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os -g" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "-O3" CACHE STRING "")

set(cortex-m0_DEFINES
    -mcpu=cortex-m0
    -mthumb
    -mabi=aapcs
    -mfloat-abi=soft)

set(cortex-m4f_DEFINES
    -mcpu=cortex-m4
    -mthumb
    -mabi=aapcs
    -mfloat-abi=hard
    -mfpu=fpv4-sp-d16)

function (set_target_link_options target_name linker_file)
    set(link_flags
        ${${ARCH}_DEFINES}
        "-Wl,--gc-sections --specs=nano.specs -L\"${${PLATFORM}_LINK_INCLUDE_DIR}\" \"-L${CMAKE_CURRENT_SOURCE_DIR}/linker\""
        "-Xlinker -Map=\"${CMAKE_CURRENT_BINARY_DIR}/${target_name}.map\""
        "-T\"${linker_file}.ld\"")

    string(REGEX REPLACE ";" " " link_flags "${link_flags}")
    set_target_properties(${target_name} PROPERTIES LINK_FLAGS ${link_flags})
endfunction (set_target_link_options)

function (create_hex executable)
    add_custom_command(
        TARGET ${executable}
        POST_BUILD
        COMMAND arm-none-eabi-objcopy -O ihex ${CMAKE_CURRENT_BINARY_DIR}/${executable}.elf ${CMAKE_CURRENT_BINARY_DIR}/${executable}.hex)
endfunction(create_hex)

