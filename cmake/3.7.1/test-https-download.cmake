# Test download a file over HTTPS to verify that this version of cmake links to
# an SSL/TLS-enabled libcurl

set(FILE_NAME "LICENSE.TXT")
set(FILE_SHA1 "e074bccff9392973400d3ea7ec6ba63d39b5fa42")
set(REMOTE_URL "https://raw.githubusercontent.com/lab7/biobuilds/master/${FILE_NAME}")

file(
    DOWNLOAD ${REMOTE_URL}
    ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}
    SHOW_PROGRESS
    EXPECTED_HASH SHA1=${FILE_SHA1}
    STATUS STATUS
    TLS_VERIFY ON
    )

# Unpack "STATUS" list
list(GET STATUS 0 RETVAL)
list(GET STATUS 1 MSG)

if(NOT RETVAL EQUAL 0)
    message(FATAL "File download error: ${MESSAGE}")
endif()
