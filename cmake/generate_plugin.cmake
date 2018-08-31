# ============================================================================
#                  SeqAn - The Library for Sequence Analysis
# ============================================================================
#
# Copyright (c) 2006-2018, Knut Reinert & Freie Universitaet Berlin
# Copyright (c) 2016-2018, Knut Reinert & MPI Molekulare Genetik
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Knut Reinert or the FU Berlin nor the names of
#       its contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL KNUT REINERT OR THE FU BERLIN BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
# ============================================================================

# Include some global variable definitions used by multiple cmake files.
include (global_vars)

# Read the mime type file and parse it into the proper xml schema.
macro (read_mimetypes mime_type_file target_xml)
    if (EXISTS ${mime_type_file})
        FILE(READ "${mime_type_file}" contents)

        # Convert file contents into a CMake list (where each element in the list
        # is one line of the file)
        #
        STRING(REGEX REPLACE ";" "\\\\;" contents "${contents}")
        STRING(REGEX REPLACE "\n" ";" contents "${contents}")

        set (${target_xml} "")

        foreach (mime_type_element ${contents})
            #message (STATUS "Line: ${mime_type_element}")
            string(REPLACE " " ";" mime_type_element_list ${mime_type_element})
            list(LENGTH mime_type_element_list mime_type_element_list_length)

            if ("${mime_type_element_list_length}" LESS "2")
                message (WARNING "Invalid mime type definition found: ${mime_type_element}."
                                 "This mime type element will be ignored for the plugin generation."
                                 "Note, this might cause errors when using the plugin in KNIME.")
            endif ()

            list (GET mime_type_element_list 0 _mime_type_name)
            string(APPEND ${target_xml} "<mimetype name=\\\"${_mime_type_name}\\\">\n")
            list (REMOVE_AT mime_type_element_list 0)
            foreach (elem ${mime_type_element_list})
                string(APPEND ${target_xml} "    <fileextension name=\\\"${elem}\\\"/>\n")
            endforeach ()
            string (APPEND ${target_xml} "</mimetype>\n")
        endforeach ()
    else ()
        message (SEND_ERROR "Could not read mime.types file: ${mime_type_file}")
    endif ()
endmacro (read_mimetypes)

# Holds all target's defined by seqan3_test
set_property (GLOBAL PROPERTY feature_generation_all_plugins "")

# Adds a plugin target for the specified target name.
macro (add_plugin plugin_name)

    set (target "${plugin_name}")
    # set (plugin_build_dir "${PROJECT_BINARY_DIR}/plugins")
    # set (plugin_script_dir "${PROJECT_BINARY_DIR}/scripts")

    message (STATUS "Register plugin ${target}")
    if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

        # First extract the mimetypes from the plugin.
        read_mimetypes(${CMAKE_CURRENT_SOURCE_DIR}/mime.types mimetype_xml)

        string (REPLACE "." "/" plugin_src_domain ${PLUGIN_DOMAIN})
        message (STATUS "plugin_src_domain: ${plugin_src_domain}")

        # Create a plugin cmake file for the specific target.
        configure_file(${plugin_cmake_dir}/build_plugin.cmake.in ${plugin_script_dir}/build_plugin_${target}.cmake @ONLY)

        # Copies the template plugin to the build dir and adapts all naming changes.
        add_custom_command (
            OUTPUT ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}
            # Copy the plugin template
            COMMAND ${CMAKE_COMMAND} -E copy_directory  ${template_dir}/${plugin_template} ${plugin_build_dir}/${plugin_template}
            # Rename the base directory and copy the source classes.
            COMMAND ${CMAKE_COMMAND} -E rename ${plugin_build_dir}/plugin ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/${plugin_src_domain}/${target}
            COMMAND ${CMAKE_COMMAND} -E copy ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/GeneratedNodeBundleActivator.java ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/${plugin_src_domain}/${target}/
            COMMAND ${CMAKE_COMMAND} -E copy ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/GeneratedNodeFactory.java ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/${plugin_src_domain}/${target}/
            COMMAND ${CMAKE_COMMAND} -E copy ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/GeneratedNodeSetFactory.java ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/${plugin_src_domain}/${target}/
            COMMAND ${CMAKE_COMMAND} -E copy ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/plugin.properties ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/${plugin_src_domain}/${target}/
            # Delete the source classes.
            COMMAND ${CMAKE_COMMAND} -E remove ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/GeneratedNodeBundleActivator.java
            COMMAND ${CMAKE_COMMAND} -E remove ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/GeneratedNodeFactory.java
            COMMAND ${CMAKE_COMMAND} -E remove ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/GeneratedNodeSetFactory.java
            COMMAND ${CMAKE_COMMAND} -E remove ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/src/plugin.properties
            # BYPRODUCTS seqan3_coverage.baseline seqan3_coverage.captured seqan3_coverage.total

            WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
            COMMENT "${target}: Generating plugin template directory."
        )

        # Source the generated plugin cmake file which is used to replace the content in the template.
        add_custom_command(
            OUTPUT ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/plugin.xml
            COMMAND ${CMAKE_COMMAND} -P ${plugin_script_dir}/build_plugin_${target}.cmake
            DEPENDS ${plugin_script_dir}/build_plugin_${target}.cmake
                    ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
            COMMENT "${target}: Adapting plugin specific variables"
            VERBATIM)

        # Find all ctd files in the current tool directory.
        file (GLOB cdt_files
              RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
              ${CMAKE_CURRENT_SOURCE_DIR}/*.ctd)

        # The following variable lists all fragment platforms that need to be generated for
        # the current plugin.
        set (${target}_fragments "")
        # Iterate through all detected descriptor files and find a suitable binary with the
        # same name.
        foreach (tool_ctd ${cdt_files})
            message (STATUS "Detect available platforms for CTD: ${tool_ctd}")
            get_filename_component(tool_name ${tool_ctd} NAME_WE)

            # Extract all platform names depending on the binary provided.
            file (GLOB_RECURSE tool_fragments
                  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
                  ${CMAKE_CURRENT_SOURCE_DIR}/*/${tool_name}*)

            # Pass over the list of detected platforms (converted to fragments in plugin generation step)
            foreach (fragment ${tool_fragments})
                # The directory should be the name of the platform, e.g.
                # `macosx_x86_64` or `win32_x86` etc.
                get_filename_component (fragment_name ${fragment} DIRECTORY)
                # The binary name including the proper extension
                get_filename_component (bin_name ${fragment} NAME)
                # Check if the current fragment_name was already set in the list of fragments.
                string(FIND "${${target}_fragments}" "${fragment_name}" _pos)
                if ("${_pos}" EQUAL "-1")
                    # if not add the fragment to the generator list.
                    set(${target}_fragments "${fragment_name};${${target}_fragments}")
                endif ()
                # Add the binary name to the current fragment component.
                set (${target}_${fragment_name} "${bin_name};${${target}_${fragment_name}}")
            endforeach ()

            # If no binary could be found for given CTD, then we will ignore this
            # binary.
            if (NOT ${${tool_name}_platforms})
                message (WARNING "Could not find binaries for ${tool_cdt}.")
            endif ()
        endforeach ()

        if ("${${target}_fragments}")
            message (WARNING "Could not find suitable payload. Skipping plugin generation for ${target}.")
            continue ()
        endif ()

        message (STATUS "Bin: ${tool_name}")
        foreach (platform ${${target}_fragments})

            # Extract osgi specific information for the fragment
            string (REGEX MATCH "(win32|macosx|linux)" osgi_os ${platform})
            string (REGEX MATCH "(x86|x86_64)$" osgi_arch ${platform})

            # Generate p2.inf content
            set (p2inf "instructions.install=")
            foreach (bin ${${target}_${platform}})
                set(p2inf "${p2inf}org.eclipse.equinox.p2.touchpoint.eclipse.chmod(targetDir:@artifact,targetFile:payload/bin/${bin},permissions:755);")
            endforeach ()
            # Configure fragment specific cmake file.
            configure_file(${plugin_cmake_dir}/build_plugin_fragment.cmake.in ${plugin_script_dir}/build_plugin_fragment_${target}_${osgi_os}_${osgi_arch}.cmake @ONLY)

            # Copy the fragment template and replace the fragment specific names.
            add_custom_command (
                OUTPUT ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}
                # Copy the plugin template
                COMMAND ${CMAKE_COMMAND} -E copy_directory ${template_dir}/${FRAGMENT_TEMPLATE} ${plugin_build_dir}/${FRAGMENT_TEMPLATE}
                # Rename the fragment directory.
                COMMAND ${CMAKE_COMMAND} -E rename ${plugin_build_dir}/fragment ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}
                # BYPRODUCTS seqan3_coverage.baseline seqan3_coverage.captured seqan3_coverage.total
                DEPENDS ${plugin_script_dir}/build_plugin_fragment_${target}_${osgi_os}_${osgi_arch}.cmake
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                COMMENT "${target}-${platform}: Generating fragment template directory."
                VERBATIM)

            # Configure the fragment settings.
            add_custom_command(
                OUTPUT ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/plugin.xml
                COMMAND ${CMAKE_COMMAND} -P ${plugin_script_dir}/build_plugin_fragment_${target}_${osgi_os}_${osgi_arch}.cmake
                DEPENDS ${plugin_script_dir}/build_plugin_fragment_${target}_${osgi_os}_${osgi_arch}.cmake
                        ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}
                COMMENT "${target}-${platform}: Configuring input files"
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                APPEND
                VERBATIM)

            # Copy the ctd and the binary to the payload direcory of the fragment.
            foreach (bin ${${target}_${platform}})

                # The binary name including the proper extension
                get_filename_component (ctd_name ${bin} NAME_WE)

                add_custom_command(
                    OUTPUT ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/plugin.xml
                    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/${ctd_name}.ctd ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}/payload/descriptors/${ctd_name}.ctd
                    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/${platform}/${bin} ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}/payload/bin/${bin}
                    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${ctd_name}.ctd
                            ${CMAKE_CURRENT_SOURCE_DIR}/${platform}/${bin}
                    COMMENT "${target}-${platform}-${bin}: Copying files to payload directory of fragment."
                    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                    APPEND
                    VERBATIM)
            endforeach ()

        endforeach ()

        # Register target for tool
        add_custom_target(
            ${target}_plugin ALL
            DEPENDS ${plugin_build_dir}/${PLUGIN_DOMAIN}.${target}/plugin.xml
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
            COMMENT "${target}: Generating plugin."
            VERBATIM)

        set_property(GLOBAL APPEND PROPERTY feature_generation_all_plugins ${target}_plugin)
    else()
        MESSAGE (STATUS "The tool directory: ${target} is not a directory.")
    endif ()

    # unset (plugin_build_dir)
    # unset (plugin_script_dir)
    unset (${target})
endmacro (add_plugin)
