==========================================
Windows Installation Guide
==========================================

Prerequisites
=============

1. **Visual Studio 2022** with:
   - Desktop Development with C++
   - C++ Make Tools for Windows

2. **MATLAB R2025b** (or compatible version)

3. **CMake** (included with Visual Studio)

4. **Java** (verify with ``java -version``)

5. **Dependencies** - Download 64-bit Windows binaries from: ``http://xmlsoft.org/sources/win32/64bit/``
   - iconv, libtool, libxml2, libxslt, openssl, xmlsec1, zlib

6. **Saxon HE 12.9** JAR file from: ``https://downloads.saxonica.com/SaxonJ/HE/12/index.html``


Setup vcpkg
===========

.. code-block:: batch

    git clone https://github.com/microsoft/vcpkg.git
    cd vcpkg
    bootstrap-vcpkg.bat


Configure PowerShell Environment
================================

Run these commands in PowerShell before building:

.. code-block:: powershell

    $env:PATH += ";C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\"
    $env:PATH += ";C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\bin\HostX86\x86"
    $env:PATH += ";<VCPKG_INSTALLATION_PATH>"
    $env:SaxonHE_CLASSPATH = "<SAXON_JAR_PATH>/saxon-he-12.9.jar"
    $env:PATH += ";<DEPENDENCIES_PATH>/iconv/bin;<DEPENDENCIES_PATH>/libtool/bin;<DEPENDENCIES_PATH>/libxml2/bin;<DEPENDENCIES_PATH>/libxslt/bin;<DEPENDENCIES_PATH>/openssl/bin;<DEPENDENCIES_PATH>/xmlsec1/bin;<DEPENDENCIES_PATH>/zlib/bin"
    $env:LIB += ";<DEPENDENCIES_PATH>/iconv/lib;<DEPENDENCIES_PATH>/libtool/lib;<DEPENDENCIES_PATH>/libxml2/lib;<DEPENDENCIES_PATH>/libxslt/lib;<DEPENDENCIES_PATH>/openssl/lib;<DEPENDENCIES_PATH>/xmlsec1/lib;<DEPENDENCIES_PATH>/zlib/lib"


Build Configuration
===================

**Debug Build:**

.. code-block:: bash

    cmake -Bbuild -S . -DVCPKG=ON -DAL_PYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX="<INSTALL_PATH>" -DCMAKE_TOOLCHAIN_FILE="<VCPKG_PATH>/scripts/buildsystems/vcpkg.cmake" -DAL_DOWNLOAD_DEPENDENCIES=ON -DAL_EXAMPLES=OFF -DAL_TESTS=OFF -DAL_PLUGINS=OFF -DAL_HLI_DOCS=OFF -DAL_DOCS_ONLY=OFF -DDD_VERSION="3.39.0" -DLIBXSLT_XSLTPROC_EXECUTABLE="<XSLTPROC_PATH>/xsltproc.exe" -DAL_BACKEND_UDA=OFF -DAL_BACKEND_UDAFAT=OFF -DAL_BACKEND_MDSPLUS=OFF -DSaxonHE_CLASSPATH="<SAXON_CLASSPATH>/saxon-he-12.9.jar"

**Release Build:**

.. code-block:: bash

    cmake -Bbuild -S . -DCMAKE_BUILD_TYPE=Release -DVCPKG=ON -DAL_PYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX="<INSTALL_PATH>" -DCMAKE_TOOLCHAIN_FILE="<VCPKG_PATH>/scripts/buildsystems/vcpkg.cmake" -DAL_DOWNLOAD_DEPENDENCIES=ON -DAL_EXAMPLES=OFF -DAL_TESTS=OFF -DAL_PLUGINS=OFF -DAL_HLI_DOCS=OFF -DAL_DOCS_ONLY=OFF -DDD_VERSION="3.39.0" -DLIBXSLT_XSLTPROC_EXECUTABLE="<XSLTPROC_PATH>/xsltproc.exe" -DAL_BACKEND_UDA=OFF -DAL_BACKEND_UDAFAT=OFF -DAL_BACKEND_MDSPLUS=OFF -DSaxonHE_CLASSPATH="<SAXON_CLASSPATH>/saxon-he-12.9.jar"


Build and Install
=================

.. code-block:: bash

    cmake --build build --config Release --target install


Using in MATLAB
===============

Example MATLAB script to access IMAS data:

.. code-block:: matlab

    % Set PATH to find all required DLLs
    setenv('PATH', [getenv('PATH') ...
        ';<IMAS_MATLAB_PATH>\build\Release' ...
        ';<IMAS_MATLAB_PATH>\matlab' ...
        ';<IMAS_MATLAB_PATH>\build\_deps\al-core-build\Release' ...
        ';<IMAS_MATLAB_PATH>\build\vcpkg_installed\x64-windows\bin']);

    % Add MATLAB helper functions and MEX files
    addpath('<IMAS_MATLAB_PATH>\matlab');
    addpath('<IMAS_MATLAB_PATH>\build\Release');

    % Open IMAS pulse file
    uri = 'imas:hdf5?path=<PATH_TO_DATA_FILE>';
    ctx = imas_open(uri, 40);
    if ctx < 0
        error('Unable to open pulse');
    end

    % Get IDS structure
    try
        m = ids_get(ctx, 'waves');
        disp('Success!')
    catch ME
        disp(['Error: ' ME.message])
    end

    % Display results
    disp('=== IDS Properties ===');
    disp(['Comment: ' m.ids_properties.comment]);
    disp(['Data Dictionary: ' m.ids_properties.version_put.data_dictionary]);


Run MATLAB Tests
================

.. code-block:: bash

    matlab -batch "test_code"


Troubleshooting
===============

- Ensure all PowerShell environment variables are set before running CMake
- Verify Visual Studio C++ build tools are installed
- Check that all dependencies are accessible at the specified network paths
- Confirm Java installation with ``java -version``
