set(LZO_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

if(NOT LZO_LIBRARIES)
  _find_package(${ARGS})
endif()

set(CMAKE_MODULE_PATH ${LZO_PREV_MODULE_PATH})