# Pskel

A simple, fast, and convenient PHP Extension skeleton project

## Overview

Pskel is a skeleton project designed to streamline the development of PHP extensions.

It provides a comprehensive toolkit that covers everything from setting up the development environment to continuous integration.

## Key Features

### 🚀 Rapid Environment Setup
- Utilizes [Development Containers](https://containers.dev/) and [Visual Studio Code](https://code.visualstudio.com/)
- Automatic installation of necessary extensions
- Simplified configuration for C/C++ development environment

### 🛠 Advanced Debugging and Analysis Tools
- Built-in support for Valgrind and Sanitizer
- Integration of external services via docker compose

### 🧪 Comprehensive Testing Environment
- Testing across various PHP builds (NTS, ZTS, DEBUG, etc.)
- Easy task execution with the `pskel` command

### 🔄 Continuous Integration with GitHub Actions
- Standard tests (NTS, ZTS)
- Memory leak checks
- Sanitizer inspections
- Code coverage analysis
- Testing on Windows environments

### ☁️ Cloud Development Environment
- Support for [GitHub Codespaces](https://docs.github.com/en/codespaces)
- Development possible with just a browser

## Setup Instructions

### Preparing for Local Development

1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Install Docker / Docker Compose compatible runtime
3. Create a repository using `zeriyoshi/pskel` as a template
4. Clone locally, open in VSCode, and select "Open in Container"

### Preparing for Development in GitHub Codespaces

1. Create a repository using `zeriyoshi/pskel` as a template
2. Create a new Codespace from the WebUI under `<> Code` -> `Codespaces`

### Creating the Skeleton

After launching the development environment, run the following command in the terminal:

```bash
$ pskel init <YOUR_EXTENSION_NAME>
```

This will create an extension template in the `/ext` directory.

Additional options available in `ext_skel.php` are also supported.

## Testing

### Testing the Extension

We provide a convenient testing environment using the `pskel` command:

```bash
$ pskel test          # Test with standard PHP
$ pskel test debug    # Test with debug build PHP
$ pskel test gcov     # Generate code coverage using GCC Gcov
$ pskel test valgrind # Memory check using Valgrind
$ pskel test msan     # Check using LLVM MemorySanitizer
$ pskel test asan     # Check using LLVM AddressSanitizer
$ pskel test ubsan    # Check using LLVM UndefinedBehaviorSanitizer
```

### Testing Integration with External Services

You can integrate external services into your development environment by editing the `compose.yaml` file.
A sample MySQL configuration is included in `compose.yaml` (commented out).

### Testing on Windows Environment

Testing on Windows is possible through GitHub Actions.
A sample configuration for Windows CI is included in `.github/workflows/ci.yaml` (commented out).

## Frequently Asked Questions

### Q: Can I use debuggers like gdb or lldb?
A: Yes. All development tools are pre-installed. For example, to use gdb:

```bash
$ gdb --args <php_binary> -dextension=./modules/your_extension_name.so example.php
```

### Q: Can I use editors other than Visual Studio Code?
A: While not recommended, you can use any editor that supports [Development Containers](https://containers.dev).

### Q: What if I have other questions?
A: Feel free to ask on GitHub or [X (formerly Twitter)](https://x.com/zeriyoshi).

## License

PHP License 3.01
