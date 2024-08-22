--TEST--
test1() Basic test
--EXTENSIONS--
bongo
--FILE--
<?php
$ret = test1();

var_dump($ret);
?>
--EXPECT--
The extension bongo is loaded and working!
NULL
