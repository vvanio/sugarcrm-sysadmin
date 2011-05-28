#!/usr/bin/php
<?php

//./include/domit/xml_domit_shared.php:   function generateUID() {
//include/HTTP_WebDAV_Server/Server.php:    function _new_uuid()

define('sugarEntry', 1);
require_once ('include/utils/LogicHook.php');
require_once ('include/utils.php');

$cnt = 1;
if ($argc > 1)
  $cnt = intval($argv[1]);

for($i=0;$i<$cnt;$i++)
{
  print create_guid() ."\n";
}

?>
