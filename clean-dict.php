#!/usr/bin/php
<?php

/**
 * Date: 2010-09-22
 * Author: B. van Berkum  <berend@brixcrm.nl>
 * 
 * Clean-up associative arrays in PHP.
 *
 * Pass the source file, the name of the array and optionally a depth at which 
 * to print split the array export (default: 3).
 *
 */

function export_array($dict, $name, $path)
{
    $arr_path = '';
    foreach($path as $key)
    {
        $arr_path .= '["' . $key . '"]';
    }
    echo "$$name$arr_path = ";
    var_export( $dict );
    echo ";\n\n\n";
}

function export_arrays($dict, $name, $at_level, $path)
{
    if (sizeof($path) == $at_level)
        export_array($dict, $name, $path);
    else
    {
        assert (is_array($dict)) or print("Need array");
        foreach ($dict as $key => $value)
        {
            array_push($path, $key);
            export_arrays($value, $name, $at_level, $path);
            array_pop($path);
        }
    }
}

function main($argv)
{
    $len = sizeof($argv);
    if (!(($len >= 3) && ($len <= 4))) 
    {
        print("Need $len arguments: source-file, array-name[, split-at-depth]\n");
        die(-1);
    }

    $raw = file_get_contents( trim( $argv[1] ) );
    $dictname = $argv[2];
    $lvl = ($len >= 4) ? intval($argv[3]) : 3;

    if (substr($raw, 0, 5) == '<?php')
        $raw = substr($raw, 5);
    if (substr($raw, -2) == '?>')
        $raw = substr($raw, 0, -2);
    $o = eval( $raw );
    //$dict = $GLOBALS[$dictname];
    $dict = eval("return \$$dictname;");

    echo "<?php\n\n";
    echo "if(!defined('sugarEntry') || !sugarEntry) die('Not A Valid Entry Point');\n";
    export_arrays($dict, $dictname, $lvl, array());
    echo "?>";
}

define('sugarEntry',true);

main($argv);

?>
