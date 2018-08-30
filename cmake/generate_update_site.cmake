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


macro (update_site_add_feature feature_list feature)

    string (APPEND ${feature_list}
        "<includes\n"
        "\tid=\"${feature}\"\n"
        "\tversion=\"0.0.0\"/>\n\n"
     )
endmacro (update_site_add_feature)

macro (collect_update_site_includes output)

    set (${output} "")

    file (GLOB PLUGINS
          RELATIVE ${PLUGIN_BUILD_DIR}
          ${PLUGIN_BUILD_DIR}/[!.]*)

    # Scan the plugin dir and add all features.
    foreach (feature ${PLUGINS})
        message (STATUS "Add feature ${feature}" )
        string (REGEX MATCH ".feature" is_feature "${feature}")

        if (NOT "${is_feature}" STREQUAL "") # Found feature to be included.

            if (NOT EXISTS ${PLUGIN_BUILD_DIR}/${feature}/feature.xml)
                message (FATAL_ERROR "Could not find feature.xml in ${PLUGIN_BUILD_DIR}/${feature}. Is the feature configured correctly?")
            endif ()
            update_site_add_feature(${output} ${feature})
        endif ()  # Register the plugin
    endforeach ()
endmacro (collect_update_site_includes)

macro (add_update_site name id)

    require_director ()

    set (update_site_label "${name}")
    set (update_site_id "${id}")

    # Create a plugin cmake file for the specific target.
    configure_file(${PLUGIN_CMAKE_DIR}/build_update_site.cmake.in ${PLUGIN_SCRIPT_DIR}/build_update_site_${id}.cmake @ONLY)

    get_property (REGISTERED_FEATURES GLOBAL PROPERTY FEATURE_GENERATION_ALL_FEATURES)

    add_custom_command(
        OUTPUT ${PLUGIN_BUILD_DIR}/${id}/feature.xml
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${TEMPLATE_DIR}/${UPDATE_SITE_TEMPLATE} ${PLUGIN_BUILD_DIR}/${id}
        # # Rename the fragment directory.
        # COMMAND ${CMAKE_COMMAND} -E rename ${PLUGIN_BUILD_DIR}/fragment ${PLUGIN_BUILD_DIR}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}
        # Execute the feature cmake script
        COMMAND ${CMAKE_COMMAND} -P ${PLUGIN_SCRIPT_DIR}/build_update_site_${id}.cmake
        DEPENDS ${REGISTERED_FEATURES}
        COMMENT "${name}: Configuring update site."
        VERBATIM
    )

    ExternalProject_Get_Property(director_project PREFIX)
    set (vendor_dir "${PREFIX}/..")
    message (STATUS "The output prefix: ${vendor_dir}")

    set (buckminster_workspace "${PROJECT_BINARY_DIR}/${PREFIX}/../workspace")

    configure_file(${PLUGIN_CMAKE_DIR}/materialize_update_site.cmake.in ${PLUGIN_SCRIPT_DIR}/materialize_update_site_${update_site_id}.cmake @ONLY)

    add_custom_target(
        ${name}_update_site ALL
        COMMAND ${CMAKE_COMMAND} -P ${PLUGIN_SCRIPT_DIR}/materialize_update_site_${update_site_id}.cmake
        DEPENDS ${PLUGIN_BUILD_DIR}/${id}/feature.xml
                director_project-build
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "${name}: Generating update site."
        VERBATIM
    )

    ExternalProject_Get_Property(director_project PREFIX)
    set (vendor_dir "${PREFIX}/..")
    message (STATUS "The output prefix: ${vendor_dir}")
 #    get_property(TEST_COVERAGE_ALL_TESTS GLOBAL PROPERTY TEST_COVERAGE_ALL_TESTS)
 # add_custom_command (
 #     OUTPUT ${PROJECT_BINARY_DIR}/seqan3_coverage
 #     DEPENDS ${TEST_COVERAGE_ALL_TESTS}
 #     APPEND
    unset (update_site_id)
    unset (update_site_label)
endmacro (add_update_site)

macro (require_director)

    include (ExternalProject)
    ExternalProject_Add (
        director_project
        PREFIX "vendor2/director"
        URL "https://github.com/genericworkflownodes/dynamicPluginGeneration/raw/master/buckminster/director_latest.zip"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PROJECT_BINARY_DIR}/vendor2/director/src/director_project/director
                       -r "http://download.eclipse.org/tools/buckminster/headless-4.4"
                       -r "http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/releases/mars"
                       -r "http://update.knime.org/build/3.1"
                       -d "${PROJECT_BINARY_DIR}/vendor2/bucky"
                       -p "Buckminster"
                       -i "org.knime.features.build.feature.group"
                       -i "org.eclipse.buckminster.cmdline.product"
                       -i "org.eclipse.buckminster.core.headless.feature.feature.group"
                       -i "org.eclipse.buckminster.pde.headless.feature.feature.group"
                       -i "org.eclipse.buckminster.git.headless.feature.feature.group"
        STEP_TARGETS build
        UPDATE_DISCONNECTED yes
    )
endmacro ()
