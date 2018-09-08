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

    file (GLOB_RECURSE FEATURES
          RELATIVE ${plugin_build_dir}
          ${plugin_build_dir}/feature.xml)

    # Scan the plugin dir and add all features.
    foreach (feature ${FEATURES})
        message (STATUS "Add feature ${feature}")
        # string (REGEX MATCH ".feature" is_feature "${feature}")
        #
        # if (NOT "${is_feature}" STREQUAL "") # Found feature to be included.
        #
        #     if (NOT EXISTS ${plugin_build_dir}/${feature}/feature.xml)
        #         message (FATAL_ERROR "Could not find feature.xml in ${plugin_build_dir}/${feature}. Is the feature configured correctly?")
        #     endif ()
        #     update_site_add_feature(${output} ${feature})
        # endif ()  # Register the plugin

        update_site_add_feature(${output} ${feature})
    endforeach ()
endmacro (collect_update_site_includes)

macro (add_update_site name id)

    require_director ()

    set (update_site_label "${name}")
    set (update_site_id "${id}")

    # Create a plugin cmake file for the specific target.
    configure_file(${plugin_cmake_dir}/build_update_site.cmake.in ${plugin_script_dir}/build_update_site_${id}.cmake @ONLY)

    get_property (REGISTERED_FEATURES GLOBAL PROPERTY FEATURE_GENERATION_ALL_FEATURES)

    # Workspace
    set (buckminster_workspace "${PROJECT_BINARY_DIR}/vendor/workspace")
    configure_file(${plugin_cmake_dir}/materialize_update_site.cmake.in ${plugin_script_dir}/materialize_update_site_${update_site_id}.cmake @ONLY)

    #
    add_custom_command(
        OUTPUT ${plugin_build_dir}/${id}/feature.xml
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${template_dir}/${update_site_template} ${plugin_build_dir}/${id}
        # Execute the feature cmake script
        COMMAND ${CMAKE_COMMAND} -P ${plugin_script_dir}/build_update_site_${id}.cmake
        COMMAND ${CMAKE_COMMAND} -P ${plugin_script_dir}/materialize_update_site_${update_site_id}.cmake
        DEPENDS ${REGISTERED_FEATURES}
        COMMENT "${name}: Configuring update site."
        VERBATIM
    )

    add_custom_target(
        ${name}_update_site ALL
        COMMAND ${buckminster_workspace}/../bucky/buckminster -data . -P buckminster.properties -S commands.txt | true
        COMMAND ${buckminster_workspace}/../bucky/buckminster -data . -P buckminster.properties -S commands.txt #NOTE: At the moment we need to execute it twice.
        COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/site
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${buckminster_workspace}/buckminster.output/${update_site_id}_${UPDATE_SITE_VERSION_MAJOR}.${UPDATE_SITE_VERSION_MINOR}.${UPDATE_SITE_VERSION_PATCH}-eclipse.feature/site.p2 ${PROJECT_BINARY_DIR}/site
        DEPENDS ${plugin_build_dir}/${id}/feature.xml
               director_project-build
        WORKING_DIRECTORY ${buckminster_workspace}
        COMMENT "${name}: Building update site."
        VERBATIM
    )

    unset (update_site_id)
    unset (update_site_label)
endmacro (add_update_site)

macro (require_director)

    include (ExternalProject)
    ExternalProject_Add (
        director_project
        PREFIX "vendor/director"
        URL "https://github.com/genericworkflownodes/dynamicPluginGeneration/raw/master/buckminster/director_latest.zip"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PROJECT_BINARY_DIR}/vendor/director/src/director_project/director
                       -r "http://download.eclipse.org/tools/buckminster/headless-4.4"
                       -r "http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/releases/mars"
                       -r "http://update.knime.org/build/3.1"
                       -d "${PROJECT_BINARY_DIR}/vendor/bucky"
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
