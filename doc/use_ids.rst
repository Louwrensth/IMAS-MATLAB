
.. highlight:: matlab

.. include:: ../../doc_common/use_ids.rst

.. |lang| replace:: MATLAB

.. |create_ids_text| replace:: calling :mat:func:`ids_init`, for example :code:`ids_init('core_profiles')`
.. |copy_ids| replace:: putting it to the memory backend and getting it again
.. |deallocate_ids_text| replace:: In MATLAB you can do this by setting the IDS variable to an empty array.

.. |structures_type| replace:: structure
.. |structures_child_attribute| replace:: structure fields
.. |aos_type| replace:: cell array
.. |aos_default| replace:: an empty cell array
.. |aos_resize_meth| replace:: :mat:func:`ids_allocate`
.. |aos_resize_keep_meth| replace:: cell array concatenation (as in below example)

.. |str_type| replace:: char array
.. |str_1d_type| replace:: cell array of char
.. |int_type| replace:: int
.. |int_nd_type| replace:: array of int
.. |double_type| replace:: double
.. |double_nd_type| replace:: array of double
.. |complex_type| replace:: double (with complex attribute)
.. |complex_nd_type| replace:: array of double (with complex attribute)

.. |str_default| replace:: empty char array (``''``)
.. |str_1D_default| replace:: empty cell array
.. |int_default| replace:: :code:`-999999999`
.. |double_default| replace:: :code:`-9e40`
.. |complex_default| replace:: :code:`-9e40 -9e40i`
.. |ND_default| replace:: empty array

.. |isFieldValid| replace:: \ 

.. |tm_homogeneous| replace:: ``IDS_TIME_MODE_HOMOGENEOUS``
.. |tm_heterogeneous| replace:: ``IDS_TIME_MODE_HETEROGENEOUS``
.. |tm_independent| replace:: ``IDS_TIME_MODE_INDEPENDENT``

.. todo
    .. |ids_validate| replace:: :py:meth:`ids.validate <imas.ids_base.IDSBase.validate>`
    .. |validate_error| replace:: raises an error
