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

### 📦 PIE による配布
- `pskel init` が [PIE](https://github.com/php/pie) に必要な `php-ext` メタデータを含む `composer.json` を生成
- タグを push すると、事前パッケージ済みソースアーカイブと Windows バイナリを添付した GitHub Release を自動作成

### ☁️ クラウド開発環境
- [GitHub Codespaces](https://docs.github.com/en/codespaces)のサポート
- ブラウザのみで開発可能

## セットアップ手順

### ローカル環境での開発準備

1. [Visual Studio Code](https://code.visualstudio.com/) をインストール
2. Docker / Docker Compose 互換ランタイムをインストール
3. `colopl/pskel` をテンプレートとしてリポジトリを作成
4. ローカルにクローンして VSCode で開き、開発コンテナーで再度開く

### GitHub Codespaces での開発準備

1. `colopl/pskel` をテンプレートとしてリポジトリを作成
2. WebUI 上の `<> Code` -> `Codespaces` から新規 Codespace を作成

### スケルトンの作成

開発環境起動後、ターミナルで以下のコマンドを実行します。

```bash
$ pskel init <YOUR_EXTENSION_NAME> "<COPYRIGHT_HOLDER / VENDOR_NAME>"
```

これにより、 `ext` ディレクトリに拡張機能の雛形が作成され、 `LICENSE` や `composer.json` などのプロジェクトメタデータがプロジェクトルートに出力されます。

`ext_skel.php` で利用可能な追加オプションもサポートしています。

## テスト

### 拡張機能のテスト

`pskel` コマンドを使用した便利なテスト環境を提供しています：

```bash
$ pskel test              # 通常のPHPによるテスト
$ pskel test debug        # デバッグビルドPHPでのテスト
$ pskel test gcov         # GCC Gcovによるコードカバレッジ生成
$ pskel test valgrind     # Valgrindによるメモリチェック
$ pskel test msan         # LLVM MemorySanitizerによるチェック
$ pskel test asan         # LLVM AddressSanitizerによるチェック
$ pskel test ubsan        # LLVM UndefinedBehaviorSanitizerによるチェック
$ pskel clean-build-cache # ビルド済みPHPランタイムとキャッシュを削除
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
Reading tracefile ext/lcov.info
            |Lines       |Functions  |Branches
Filename    |Rate     Num|Rate    Num|Rate     Num
==================================================
[ext/]
bongo.c     |75.0%     20|80.0%     5|    -      0
==================================================
      Total:|75.0%     20|80.0%     5|    -      0
```

### GitHub Pages での確認

リポジトリの GitHub Pages を有効にし、 Actions による deploy を有効にすることで `lcov` および `genhtml` コマンドによって生成されたコードカバレッジを GitHub Pages で閲覧できるようになります。

## PIE によるリリース

[PIE](https://github.com/php/pie) は PHP 拡張機能を配布するための標準的なインストーラーです。

`pskel init` は PIE に必要な `php-ext` メタデータを含む `composer.json` を生成します。タグ (例: `1.0.0`) を push すると、 `Release` ワークフローが自動的に以下を行います。

1. タグに対応する GitHub Release の作成
2. 事前パッケージ済みソースアーカイブ (`php_<extension_name>-<version>-src.tgz`) の添付
3. [php/php-windows-builder](https://github.com/php/php-windows-builder) による Windows バイナリ (PHP 8.1 - 8.5, x64/x86, TS/NTS) のビルドと添付

`pie install <vendor>/<extension_name>` でインストール可能にするには、リポジトリを [Packagist](https://packagist.org/) に登録してください。

## よくある質問

### Q: gdb や lldb などのデバッガは使用できますか？
A: はい。すべての開発ツールがプリインストールされています。例えば gdb を使用する場合：

```bash
$ gdb --args <php_binary> -dextension=./modules/your_extension_name.so example.php
```

### Q: Valgrind はどのようにインストールされますか？
A: コンテナイメージのビルド時に [sourceware.org](https://sourceware.org/pub/valgrind/) からソースをダウンロードしてビルドされます。バージョンは `Dockerfile` のビルド引数 `VALGRIND_VERSION` で固定されています。事前に取得した `valgrind-<version>.tar.bz2` をリポジトリのトップレベルに配置すると (`.gitignore` により Git 管理外)、ダウンロードの代わりにそれが使用されます。また、ビルド引数 `SKIP_VALGRIND=1` を指定することで Valgrind のビルド自体をスキップできます。Valgrind は Debian ベースのイメージでのみサポートされるため、非 Debian (Alpine など) のイメージをビルドする場合は `SKIP_VALGRIND=1` を明示的に指定しない限りビルドは失敗します。

### Q: Visual Studio Code 以外のエディタは使用できますか？
A: 推奨はしませんが、 [Development Containers](https://containers.dev) 対応のエディタであれば使用可能です。

### Q: その他の質問がある場合は？
A: GitHub 上または [X (旧Twitter)](https://x.com/zeriyoshi) でお気軽にお問い合わせください。

## ライセンス

BSD-3-Clause
