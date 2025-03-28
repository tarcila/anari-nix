# ----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
# ----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "WebP::sharpyuv" for configuration "Release"
set_property(
  TARGET WebP::sharpyuv
  APPEND
  PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(
  WebP::sharpyuv
  PROPERTIES IMPORTED_LOCATION_RELEASE
             "${_IMPORT_PREFIX}/lib/@SHARPYUV_IMPORTED_LOCATION_RELEASE@"
             IMPORTED_SONAME_RELEASE "@SHARPYUV_IMPORTED_SONAME_RELEASE@")

list(APPEND _cmake_import_check_targets WebP::sharpyuv)
list(APPEND _cmake_import_check_files_for_WebP::sharpyuv
     "${_IMPORT_PREFIX}/lib/@SHARPYUV_IMPORTED_LOCATION_RELEASE@")

# Import target "WebP::webpdecoder" for configuration "Release"
set_property(
  TARGET WebP::webpdecoder
  APPEND
  PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(
  WebP::webpdecoder
  PROPERTIES IMPORTED_LOCATION_RELEASE
             "${_IMPORT_PREFIX}/lib/@WEBPDECODER_IMPORTED_LOCATION_RELEASE@"
             IMPORTED_SONAME_RELEASE "@WEBPDECODER_IMPORTED_SONAME_RELEASE@")

list(APPEND _cmake_import_check_targets WebP::webpdecoder)
list(APPEND _cmake_import_check_files_for_WebP::webpdecoder
     "${_IMPORT_PREFIX}/lib/@WEBPDECODER_IMPORTED_LOCATION_RELEASE@")

# Import target "WebP::webp" for configuration "Release"
set_property(
  TARGET WebP::webp
  APPEND
  PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(
  WebP::webp
  PROPERTIES IMPORTED_LOCATION_RELEASE
             "${_IMPORT_PREFIX}/lib/@WEBP_IMPORTED_LOCATION_RELEASE@"
             IMPORTED_SONAME_RELEASE "@WEBP_IMPORTED_SONAME_RELEASE@")

list(APPEND _cmake_import_check_targets WebP::webp)
list(APPEND _cmake_import_check_files_for_WebP::webp
     "${_IMPORT_PREFIX}/lib/@WEBP_IMPORTED_LOCATION_RELEASE@")

# Import target "WebP::webpdemux" for configuration "Release"
set_property(
  TARGET WebP::webpdemux
  APPEND
  PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(
  WebP::webpdemux
  PROPERTIES IMPORTED_LOCATION_RELEASE
             "${_IMPORT_PREFIX}/lib/@WEBPDEMUX_IMPORTED_LOCATION_RELEASE@"
             IMPORTED_SONAME_RELEASE "@WEBPDEMUX_IMPORTED_SONAME_RELEASE@")

list(APPEND _cmake_import_check_targets WebP::webpdemux)
list(APPEND _cmake_import_check_files_for_WebP::webpdemux
     "${_IMPORT_PREFIX}/lib/@WEBPDEMUX_IMPORTED_LOCATION_RELEASE@")

# Import target "WebP::libwebpmux" for configuration "Release"
set_property(
  TARGET WebP::libwebpmux
  APPEND
  PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(
  WebP::libwebpmux
  PROPERTIES IMPORTED_LOCATION_RELEASE
             "${_IMPORT_PREFIX}/lib/@WEBPMUX_IMPORTED_LOCATION_RELEASE@"
             IMPORTED_SONAME_RELEASE "@WEBPMUX_IMPORTED_SONAME_RELEASE@")

list(APPEND _cmake_import_check_targets WebP::libwebpmux)
list(APPEND _cmake_import_check_files_for_WebP::libwebpmux
     "${_IMPORT_PREFIX}/lib/@WEBPMUX_IMPORTED_LOCATION_RELEASE@")

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
