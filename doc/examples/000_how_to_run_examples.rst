========================================================================================================================
How to run examples
========================================================================================================================

This code examples can be run using already prepared tests in

``al-matlab/doc/code_samples/tutorial/test_new_examples.m``.

1. Change the directory to ``al-matlab/doc/code_samples/tutorial``.

.. code-block:: bash

    cd al-matlab/doc/code_samples/tutorial


2. To **compile** the code, run the following command:

.. code-block:: bash

    g++ test_new_examples.m `pkg-config --libs --cflags al-matlab` -pthread -o cplusplus



3. To **run** the code, use the following command:

.. code-block:: bash

    ./cplusplus