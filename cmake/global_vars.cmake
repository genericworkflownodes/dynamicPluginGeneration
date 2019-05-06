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

set (plugin_cmake_dir "${CMAKE_CURRENT_LIST_DIR}")
# Set the base template directory relative to this file directory.
set (template_dir "${plugin_cmake_dir}/../template")
set (BUCKMINSTER_template_dir "${plugin_cmake_dir}/../buckminster")
set (plugin_template "plugin")
set (FRAGMENT_TEMPLATE "fragment")
set (feature_template "feature")
set (update_site_template "update_site")

if (NOT IS_DIRECTORY ${template_dir}/${plugin_template})
    message (ERROR "Could not find template plugin directory in ${template_dir}")
endif ()

if (NOT IS_DIRECTORY ${template_dir}/${FRAGMENT_TEMPLATE})
    message (ERROR "Could not find template fragment directory in ${template_dir}.")
endif ()

if (NOT IS_DIRECTORY ${template_dir}/${feature_template})
    message (ERROR "Could not find template feature directory in ${template_dir}.")
endif ()

if (NOT IS_DIRECTORY ${template_dir}/${update_site_template})
    message (ERROR "Could not find template update site directory in ${template_dir}.")
endif ()

message (STATUS "template_dir: ${template_dir}")

set (plugin_build_dir "${PROJECT_BINARY_DIR}/plugins")
set (plugin_script_dir "${PROJECT_BINARY_DIR}/scripts")

macro (add_subdirectories)
    file (GLOB ENTRIES
          RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
          ${CMAKE_CURRENT_SOURCE_DIR}/[!.]*)

    foreach (ENTRY ${ENTRIES})
        if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ENTRY})
            if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${ENTRY}/CMakeLists.txt)
                add_subdirectory (${ENTRY})
            endif ()
        endif ()
    endforeach ()
    unset (ENTRIES)
endmacro ()

# Set the KNIME target platform to build the plug-ins for.
set(PLUGIN_KNIME_VERSION "3.6.0" CACHE STRING "The KNIME version to build the plugins for.")

# Set the plugin dependency
set(PLUGIN_DEPENDENCY "" CACHE INTERNAL "Adds dependencies to a generated GKN plugin" FORCE)
# Set the plugin executor
set (PLUGIN_EXECUTOR "LocalToolExecutor" CACHE INTERNAL "Sets the tool executor for the plugin" FORCE)

# Set the plugin display layer for plug-in versions.
set (PLUGIN_VERSION_DISPLAY_LAYER "" CACHE INTERNAL "Sets the version display layer for the plugin" FORCE)
