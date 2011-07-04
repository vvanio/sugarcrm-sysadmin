<?php 

foreach (new RecursiveIteratorIterator (new RecursiveDirectoryIterator ('.')) as $x)
{
	$file = $x->getPathname ();
	if (!preg_match( "/.*\.php$/", $file )) {
		continue;
	}
	$data = file_get_contents($file);

	$count1 = 0;
	$count2 = 0;

	$matches = array();
	$m = preg_match( "/^\\v+<\?/", $data, $matches);
	if ($m) {
		$count1 = substr_count($matches[0], "\n");
	}

	$matches = array();
	$m = preg_match( "/\\?>\\v\\v+\\z$/", $data, $matches);
	if ($m) {
		$count2 = substr_count($matches[0], "\n");
	}

	if ($count2 > 1 || $count1) {
		echo("<$file> heading: $count1, trailing: $count2\n");
	}
}

?>
