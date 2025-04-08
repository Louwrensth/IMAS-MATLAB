.. include:: ./doc_common/using_al.rst

Using the Access Layer with your MATLAB program
-----------------------------------------------

The following example program will load the MATLAB interface to the Access Layer
to print the version of the access layer and data dictionary.

.. highlight:: matlab


.. literalinclude:: code_samples/imas_hello_world.m
    :caption: ``imas_hello_world.m``

.. seealso:: :ref:`Version constants`

If you save this as a file ``imas_hello_world.m``, you can run it as follows:

.. code-block:: console

    $ module load MATLAB
    [...]
    $ matlab -batch imas_hello_world
    [...]

    Hello world!
    Access Layer version info:
               al_version: '5.0.0'
              hli_version: '5.0.0'
               dd_version: '3.39.0'
        hli_version_array: [3x1 int32]
         dd_version_array: [3x1 int32]


Congratulations if this runs successfully! In the next sections of the
documentation you can see how to:

- :ref:`Loading and storing IMAS data`
- :ref:`Use Interface Data Structures`

