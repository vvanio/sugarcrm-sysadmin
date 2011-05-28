SugarCRM Administration Scripts
===============================

- To reset the admin password::

    update users set user_hash = md5('password') where user_name = 'admin';

- Command-line repair/rebuild:

  .. include:: repair-rebuild.sh
     :literal:
     :start-after: # main.rst include
     :end-before: # /main.rst include

  See `repair-rebuild.sh <repair-rebuild.sh>`__.

Other short bash scripts:  
  - `Command-line time profiling <time-profile-modules.sh>`__
  - `clean-cache <clean-cache>`__, remove cached vardefs, views etc. before running a repair/rebuild.
  - `grep-tree <clean-cache>`__, search a SugarCRM filetree for a string or pattern.
  - `permissions <permissions.sh>`__, find and correct all files with deviating user/group permissions. E.g. for new files, after new checkout.
  - `svn-ignore-ext.sh <svn-ignore-ext.sh>`__, find all Sugar generated ``*.ext.php`` files, and keep these out of ``svn``. Note that not all these files in the tree will be regenerated, only use in ``custom/modules/``.

  
