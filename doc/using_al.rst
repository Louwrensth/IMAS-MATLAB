.. include:: ../../doc_common/using_al.rst

Using the Access Layer with your MATLAB program
-----------------------------------------------

The following example program will load the Fortran interface to the Access Layer
to print the version of the access layer and data dictionary.

.. highlight:: matlab


.. literalinclude:: code_samples/imas_hello_world.m
    :caption: ``imas_hello_world.m``


If you save this as a file ``imas_hello_world.m``, you can run it as follows:

.. code-block:: console

    $ module load MATLAB
    [...]
    $ matlab -batch imas_hello_world
    [...]

    Hello world!
    Using access layer version: 5rc


Congratulations if this runs successfully! In the next sections of the
documentation you can see how to:

- :ref:`Loading and storing IMAS data`
- :ref:`Use Interface Data Structures`

