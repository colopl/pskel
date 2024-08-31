--TEST--
test1() Basic test
--EXTENSIONS--
conga
--FILE--
<?php
$ret = test1();

var_dump($ret);
?>
--EXPECT--
The extension conga is loaded and working!
NULL
