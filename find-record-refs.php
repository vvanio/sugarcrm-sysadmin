#!/usr/bin/php
<?php
/**
 * 2010-12-23
 *  Find all relations for module, then show references for record ID.
 **/

include_once('optparse.php');


/* Defaults */
$facio_dir = '/srv/facio-sam';


/* Parse ARGV */
$prsr = new OptionParser();
$prsr->add_option(array("-S", "--server-root","metavar"=>"PATH","help"=>"The Brix SugarCRM document root. This is where the .htdatabase file is expected (default: %default).",'default'=>$facio_dir));
$prsr->add_option(array("-m", "--module","metavar"=>"Name","help"=>"The module the given record ID's belong to"));
$prsr->add_option(array("-M", "--module-table","metavar"=>"TABLE","help"=>"The name of the table (if not matched by lower-cased module-name). "));

$values = $prsr->parse_args($argv);
$facio_dir = $values->options['server-root'];
$module_name = $values->options['module'];
$records = $values->positional;

if (!is_dir($facio_dir))
{
    trigger_error("Brix SugarCRM missing: $facio_dir", E_USER_ERROR);
    exit(2);
}
if (!$module_name)
{
  trigger_error("Need module name");
  exit(3);
}


/* Open DB conn */
require_once "$facio_dir/.htdatabase";
$c = mysql_connect($db_host_name, $db_user_name, $db_password);
if ($c == null)
{
    trigger_error("No DB", E_USER_ERROR);
    exit(2);
}
mysql_select_db($db_name, $c);

$module_table_name = strtolower($module_name);
fwrite(STDERR, "Using $module_name <$module_table_name>\n");

/* Get list of tables to check for obvious errors */
$rs = mysql_query("SHOW TABLES");
$tables = array();
while (list($table) = mysql_fetch_array($rs, MYSQL_NUM))
  $tables[] = $table;

if (!in_array($module_table_name, $tables))
{
  fwrite(STDERR, "Cannot continue for $module_name, not a table name: $module_table_name");
  exit(6);
}

/* Start with each record ID */
foreach($records as $id)
{
  $rs = mysql_query(
      "select name from $module_table_name where id = '$id'"
    );
  if (!$rs)
  {
    fwrite(STDERR, "No records for '$id'");
    exit(4);
  }

  list($name) = mysql_fetch_array($rs, MYSQL_NUM);
  echo "\n'$name' ($id) \n";

  /* Get related modules with: join tables and tables */

  $relations = array();
  $rs = mysql_query(
      "select relationship_name, lhs_table, lhs_key, rhs_table, rhs_key, join_table, join_key_lhs, join_key_rhs ".
      "from relationships where rhs_module = '$module_name' or lhs_module = '$module_name'"//deleted = 0"
  );
  if (!$rs)
  {
    fwrite(STDERR, "No relations for module '$module_name'\n");
    exit(3);
  }
  while (list($rel_name, $t_l, $k_l, $t_r, $k_r, $join_table, $join_key_left, $join_key_right) = mysql_fetch_array($rs, MYSQL_NUM)) 
  {
    /* query 'other' side */
    if ($t_r == $module_table_name)
      $other = array('left', $t_l, $k_l);
    else
      $other = array('right', $t_r, $k_r);

    if (!in_array($other[1], $tables))
    {
      fwrite(STDERR, "Cannot continue for relation $rel_name, not a table name: ${other[1]}");
      exit(7);
    }

    if ($join_table)
    {
      $join_key_this = $other[0] == 'left' ? $join_key_left : $join_key_right;
      $join_key_other = $other[0] == 'right' ? $join_key_left : $join_key_right;

      $rs2 = mysql_query("select count(*) from `$join_table` where `$join_key_this` = '$id'");
      if ( !$rs2 )
      {
        fwrite(STDERR, "Could not query join table for $rel_name <$join_table#$key>\n");
        fwrite(STDERR, "Because: ". mysql_error()."\n");
        continue;
      }
      list($cnt) = mysql_fetch_array($rs2, MYSQL_NUM);
      if ( $cnt < 1 )
        continue;
      echo "#\t$rel_name\n";
      $rs2 = mysql_query("select other.id, other.name from `$join_table` as j, `$other[1]` as other where j.`$join_key_this` = '$id' and j.`$join_key_other` = other.`${other[2]}`");
      if ( !$rs2 )
      {
        fwrite(STDERR, "Could not query join table for $rel_name <$join_table#${other[2]}>\n");
        fwrite(STDERR, "Because: ". mysql_error()."\n");
        continue;
      }
      fwrite(STDERR, "\t\tTODO join-table\n");
      fwrite(STDERR, "\t\t");
    }
    /* regular relation (1->1, 1->*) */
    else
    {
      $rs2 = mysql_query("select count(*) from `${other[1]}` where `${other[2]}` = '$id'");
      if ( !$rs2 )
      {
        fwrite(STDERR, "Could not query ${other[0]} side of $rel_name <${other[1]}#${other[2]}>\n");
        fwrite(STDERR, "Because: ". mysql_error()."\n");
        continue;
      }
      list($cnt) = mysql_fetch_array($rs2, MYSQL_NUM);
      if ( $cnt < 1 )
        continue;
      echo "\t$rel_name (looking ${other[0]}) <${other[1]}>:\n\t\t# id,\tname,\t${other[2]}\n";
      $rs2 = mysql_query("select id, name, ${other[2]} from `${other[1]}` where `${other[2]}` = '$id'");
      while ($row = mysql_fetch_array($rs2, MYSQL_NUM))
      {
        echo "\t\t".implode(",\t",array_map(function($s){return "'$s'";},$row))."\n";
      }
    }
  }
  //echo "\n";
}

mysql_close($c);

?>
