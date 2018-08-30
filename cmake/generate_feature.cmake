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

# Global list of all features that should be included into the update site.
set_property (GLOBAL PROPERTY FEATURE_GENERATION_ALL_FEATURES "")

macro (add_feature name id description copyright license)
    # We need to double quote `"` signs in the descriptions in order to pass them correctly to the
    # generated feature.xml file.
    string (REGEX REPLACE "&" "&amp;" copyright_quoted "${copyright}")
    string (REGEX REPLACE "&" "&amp;" description_quoted "${description}")
    string (REGEX REPLACE "&" "&amp;" license_quoted "${license}")

    string (REGEX REPLACE "\"" "&quot;" copyright_quoted "${copyright_quoted}")
    string (REGEX REPLACE "\"" "&quot;" description_quoted "${description_quoted}")
    string (REGEX REPLACE "\"" "&quot;" license_quoted "${license_quoted}")

    set (feature_label "${name}")
    set (feature_id "${id}")
    set (feature_description "${description_quoted}")
    set (feature_copyright "${copyright_quoted}")
    set (feature_license "${license_quoted}")

    # Create a plugin cmake file for the specific target.
    configure_file(${PLUGIN_CMAKE_DIR}/build_feature.cmake.in ${PLUGIN_SCRIPT_DIR}/build_feature_${id}.cmake @ONLY)

    get_property (REGISTERED_PLUGINS GLOBAL PROPERTY PLUGIN_GENERATION_ALL_PLUGINS)

    add_custom_command(
        OUTPUT ${PLUGIN_BUILD_DIR}/${id}/feature.xml
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${TEMPLATE_DIR}/${FEATURE_TEMPLATE} ${PLUGIN_BUILD_DIR}/${id}
        # # Rename the fragment directory.
        # COMMAND ${CMAKE_COMMAND} -E rename ${PLUGIN_BUILD_DIR}/fragment ${PLUGIN_BUILD_DIR}/${PLUGIN_DOMAIN}.${target}.${osgi_os}.${osgi_arch}
        # Execute the feature cmake script
        COMMAND ${CMAKE_COMMAND} -P ${PLUGIN_SCRIPT_DIR}/build_feature_${id}.cmake
        DEPENDS ${REGISTERED_PLUGINS}
        COMMENT "${name}: Configuring feature."
        VERBATIM
    )

    add_custom_target(
        ${name}_feature ALL
        DEPENDS ${PLUGIN_BUILD_DIR}/${id}/feature.xml
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "${name}: Generating feature."
        VERBATIM
    )

    set_property(GLOBAL APPEND PROPERTY FEATURE_GENERATION_ALL_FEATURES ${name}_feature)

 #    get_property(TEST_COVERAGE_ALL_TESTS GLOBAL PROPERTY TEST_COVERAGE_ALL_TESTS)
 # add_custom_command (
 #     OUTPUT ${PROJECT_BINARY_DIR}/seqan3_coverage
 #     DEPENDS ${TEST_COVERAGE_ALL_TESTS}
 #     APPEND
    unset (feature_id)
    unset (feature_label)
    unset (feature_description)
    unset (feature_copyright)
    unset (feature_license)
endmacro (add_feature)
