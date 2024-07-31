=========================================================================================================
Create DBEntry from scratch using *legacy* mode
=========================================================================================================

This example focuses on creating DBEntry using **legacy** mode method.

.. seealso::

    API documentation for :mat:func:`imas_create_env`, :mat:func:`imas_open_env`
    
.. warning::

    The legacy method is deprecated from ``AL>=5.0.0``.

    It is recommended to use the **URI** approach instead.

.. literalinclude:: ../code_samples/tutorial/example_001_open_database.m
    :start-after: % This example focuses on creating DBEntry using legacy mode method
    :end-before:  imas_close(ctx);
    :language: matlab

