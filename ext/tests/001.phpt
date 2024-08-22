--TEST--
Check if conga is loaded
--EXTENSIONS--
conga
--FILE--
<?php
echo 'The extension "conga" is available';
?>
--EXPECT--
The extension "conga" is available
