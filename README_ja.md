# Pskel

[English](README.md)

シンプル・高速・便利なPHP Extension スケルトンプロジェクト

## 概要

Pskelは、PHP拡張機能の開発を迅速かつ効率的に行うためのスケルトンプロジェクトです。

開発環境のセットアップから継続的インテグレーションまで、包括的なツールセットを提供します。

## 主な機能

### 🚀 迅速な環境セットアップ
- [Development Containers](https://containers.dev/)と[Visual Studio Code](https://code.visualstudio.com/)の活用
- 必要な拡張機能の自動インストール
- C/C++ 開発環境の簡易構成

### 🛠 高度なデバッグ・解析ツール
- Valgrind と LLVM Sanitizer のサポート
- docker compose による外部サービスの統合

### 🧪 包括的なテスト環境
- 多様なPHPビルド (NTS, ZTS, DEBUG 等) でのテスト
- `pskel` コマンドによる簡単なタスク実行

### 🔄 GitHub Actionsによる継続的インテグレーション
- 通常テスト (NTS, ZTS)
- メモリリークチェック
- LLVM Sanitizer による検査
- コードカバレッジ分析
- 各種 OS におけるテストに対応
    - Linux
    - macOS
    - Windows

### ☁️ クラウド開発環境
- [GitHub Codespaces](https://docs.github.com/en/codespaces)のサポート
- ブラウザのみで開発可能

## セットアップ手順

### ローカル環境での開発準備

1. [Visual Studio Code](https://code.visualstudio.com/) をインストール
2. Docker / Docker Compose 互換ランタイムをインストール
3. `colopl/pskel` をテンプレートとしてリポジトリを作成
4. ローカルにクローンして VSCode で開き、開発コンテナーで起動

### GitHub Codespaces での開発準備

1. `colopl/pskel` をテンプレートとしてリポジトリを作成
2. WebUI 上の `<> Code` -> `Codespaces` から新規 Codespace を作成

### スケルトンの作成

開発環境起動後、ターミナルで以下のコマンドを実行します。

```bash
$ pskel init <YOUR_EXTENSION_NAME>
```

これにより、 `/ext` ディレクトリに拡張機能の雛形が作成されます。

`ext_skel.php` で利用可能な追加オプションもサポートしています。

## テスト

### 拡張機能のテスト

`pskel` コマンドを使用した便利なテスト環境を提供しています：

```bash
$ pskel test          # 通常のPHPによるテスト
$ pskel test debug    # デバッグビルドPHPでのテスト
$ pskel test gcov     # GCC Gcovによるコードカバレッジ生成
$ pskel test valgrind # Valgrindによるメモリチェック
$ pskel test msan     # LLVM MemorySanitizerによるチェック
$ pskel test asan     # LLVM AddressSanitizerによるチェック
$ pskel test ubsan    # LLVM UndefinedBehaviorSanitizerによるチェック
```

### 外部サービスとの連携テスト

`compose.yaml` を編集することで、開発環境に外部サービスを統合できます。

MySQL のサンプル設定が `compose.yaml` にコメントアウトされた状態で含まれています。

## コードカバレッジ

### 開発環境下での確認

`pskel` コマンドで lcov を利用したカバレッジの確認を行うことができます。

```bash
$ pskel coverage
~~~
Reading tracefile /workspaces/pskel/ext/lcov.info
            |Lines       |Functions  |Branches
Filename    |Rate     Num|Rate    Num|Rate     Num
==================================================
[/workspaces/pskel/ext/]
bongo.c     |75.0%     20|80.0%     5|    -      0
==================================================
      Total:|75.0%     20|80.0%     5|    -      0
```

### GitHub Pages での確認

リポジトリの GitHub Pages を有効にし、 Actions による deploy を有効にすることで `lcov` および `genhtml` コマンドによって生成されたコードカバレッジを GitHub Pages で閲覧できるようになります。

## よくある質問

### Q: gdb や lldb などのデバッガは使用できますか？
A: はい。すべての開発ツールがプリインストールされています。例えば gdb を使用する場合：

```bash
$ gdb --args <php_binary> -dextension=./modules/your_extension_name.so example.php
```

### Q: Visual Studio Code 以外のエディタは使用できますか？
A: 推奨はしませんが、 [Development Containers](https://containers.dev) 対応のエディタであれば使用可能です。

### Q: その他の質問がある場合は？
A: GitHub 上または [X (旧Twitter)](https://x.com/zeriyoshi) でお気軽にお問い合わせください。

## ライセンス

PHP License 3.01
