# フォルダ横断メディアビューア

フォルダ名を条件にして、置き場所をまたいで写真と動画を閲覧する静的 Web ビューアです。見た目は [Simple.css](https://simplecss.org/) に任せ、OS のライト／ダークに従います。

[English version here](README.md)

## 使い方

1. このリポジトリのファイルを、写真・動画があるフォルダに置く
2. `media.json`（写真・動画の一覧）を作る（`.`で始まるファイル・フォルダは対象外）。ファイルを足したり消したりしたら再実行する
   - Windows: `update.bat` をダブルクリック（内部で `update.ps1` を実行）
   - Mac/Linux: `update.sh` を実行（内部で `update.py` を実行。Python 3が必要）
3. そのフォルダを NAS などの静的 Web で公開する
4. ブラウザで `view.html` を開く

多くのブラウザは `file://` では `media.json` を読めません。HTTP で開いてください。

## 機能

- フォルダ以下の写真・動画を再帰的に一覧化
- 種類（写真／動画）、フォルダ名、拡張子での絞り込み（拡張子は全てチェック済みの状態から始まり、ブラウザで表示できない拡張子はチェックを外すと非表示にできる）
- 選んだフォルダ名は上部に表示され、残りのフォルダボタンからは消える
- 読み込みに失敗した項目をまとめて非表示にするボタン（絞り込みの下に配置）
- 300件を超える一覧は既定では警告のみを表示し、ボタンで強制的に表示できる
- 入口スクリプトは実行後に画面を閉じず（終了時に一時停止）、実行内容を `update.log` にも書き出す

## ファイル

| ファイル | 役割 |
|---|---|
| `view.html` | ビューア本体（マークアップとロジック） |
| `update.bat` | Windows用入口。`update.ps1` を呼び、結果を確認できるよう一時停止する |
| `update.ps1` | Windowsで `media.json` を生成する |
| `update.sh` | Mac/Linux用入口。`update.py` を呼び、結果を確認できるよう一時停止する |
| `update.py` | Mac/Linuxで `media.json` を生成する（Python 3が必要） |
| `media.json` | 生成される一覧（パス・種類・拡張子）。入口スクリプトが作成し、このリポジトリには含まれない |
| `update.log` | 直近の入口スクリプト実行結果のログ |
| `simple.min.css` | 見た目用のスタイルシート。このリポジトリには含まれない（下記参照） |

## Simple.css の入手方法

`view.html` は隣に `simple.min.css` があることを前提にしていますが、このリポジトリには含まれていません。次のいずれかで用意してください。

- [Simple.css のリポジトリ](https://github.com/kevquirk/simple.css) からダウンロードし、`view.html` と同じ場所に置く
- または `view.html` 内の `<link>` タグを CDN 参照に変更する：`https://cdn.simplecss.org/simple.min.css`

## ライセンス

MIT — [LICENSE](LICENSE) を参照
