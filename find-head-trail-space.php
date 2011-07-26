#!/usr/bin/env php
<?php 

foreach (new RecursiveIteratorIterator (new RecursiveDirectoryIterator ('.')) as $x)
{
	$file = $x->getPathname ();
	if (!preg_match( "/.*\.php$/", $file )) {
		continue;
	}
	$data = file_get_contents($file);
	#$matches = array();
	#$m = preg_match( "/\\A\\v+<\\?/m", $data, $matches);
	#if ($m) {
	#	echo("$file\n");
	#	print_r($matches);
	#}
	$matches = array();
	#$m = preg_match( "/\\?".">\\v\\v+\\Z/m", $data, $matches);
	$m = preg_match( "/\\?>\\v\\v+\\z/", $data, $matches);
	if ($m) {
		echo("$file\n");
//		print_r($matches);
	}
}

?>
