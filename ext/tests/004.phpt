--TEST--
Test phpinfo()
--EXTENSIONS--
conga
--FILE--
<?php
ob_start(
    static fn (string $phpinfo): string
      => str_contains($phpinfo, 'conga support') ? 'Success' : 'Failure'
);
phpinfo();
ob_end_flush();
?>
--EXPECT--
Success
