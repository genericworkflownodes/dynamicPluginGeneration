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

set (PLUGIN_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")
# Set the base template directory relative to this file directory.
set (TEMPLATE_DIR "${PLUGIN_CMAKE_DIR}/../template")
set (BUCKMINSTER_TEMPLATE_DIR "${PLUGIN_CMAKE_DIR}/../buckminster")
set (PLUGIN_TEMPLATE "plugin")
set (FRAGMENT_TEMPLATE "fragment")
set (FEATURE_TEMPLATE "feature")
set (UPDATE_SITE_TEMPLATE "update_site")

if (NOT IS_DIRECTORY ${TEMPLATE_DIR}/${PLUGIN_TEMPLATE})
    message (ERROR "Could not find template plugin directory in ${TEMPLATE_DIR}")
endif ()

if (NOT IS_DIRECTORY ${TEMPLATE_DIR}/${FRAGMENT_TEMPLATE})
    message (ERROR "Could not find template fragment directory in ${TEMPLATE_DIR}.")
endif ()

if (NOT IS_DIRECTORY ${TEMPLATE_DIR}/${FEATURE_TEMPLATE})
    message (ERROR "Could not find template feature directory in ${TEMPLATE_DIR}.")
endif ()

if (NOT IS_DIRECTORY ${TEMPLATE_DIR}/${UPDATE_SITE_TEMPLATE})
    message (ERROR "Could not find template update site directory in ${TEMPLATE_DIR}.")
endif ()

message (STATUS "TEMPLATE_DIR: ${TEMPLATE_DIR}")

set (PLUGIN_BUILD_DIR "${PROJECT_BINARY_DIR}/plugins")
set (PLUGIN_SCRIPT_DIR "${PROJECT_BINARY_DIR}/scripts")
