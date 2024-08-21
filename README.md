# Pskel

A skeleton project for quickly setting up an environment to develop extensions for PHP.

### How to use

1. Install [Visual Studio Code](https://code.visualstudio.com/) and Docker Desktop (or an alternative engine).
1. Install the [Remote Container](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension in VSCode.
1. Open the directory and open it with the `Remote Container` extension.
1. Run `pskel init <extension_name>` .
2. Run `pskel test [debug|valgrind|msan|asan|ubsan|gcov]` command for testing.

### Q&A

#### Can I set up an environment using MySQL, Redis, etc.?

Yes. Pskel comes pre-setup with MySQL as a example. If you want to add something, you can easily do so by editing the `compose.yaml`.

#### Can I debug using gdb?

Yes. Build using the debug version of PHP and run as follows:

```
# gdb --args <php_binary> -dextension=./modules/your_extension_name.so example.php
```

#### Can I develop using something other than Visual Studio Code?

While it's not recommended, it's possible. You can using Docker Compose (or a alternative engine).

### License

PHP License 3.01
