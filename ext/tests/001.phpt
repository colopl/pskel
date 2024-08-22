--TEST--
Check if bongo is loaded
--EXTENSIONS--
bongo
--FILE--
<?php
echo 'The extension "bongo" is available';
?>
--EXPECT--
The extension "bongo" is available
