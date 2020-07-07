# ttrec_resv: TvTest/TTRec の予約内容を表示するスクリプト

## Files

| File | Description |
| ---- | ----------- |
| ttrec_resv.pl | 本体 |
| ttrec_resv_pl.sh | ttrec_resv.pl 呼び出しスクリプト |

## 前提

Git Bash をインストールしてあること。

## 使用法

1. `ttrec_recv.pl`, `ttrec_resv_pl.sh` を適当なフォルダに置く。
2. `ttrec_resv_pl.sh` へのショートカットを使いやすい場所に作成する。
3. ショートカットのプロパティを編集し、リンク先」に次の内容を入力する
   ```
   "C:\Program Files\Git\bin\sh.exe" -l "C:\soft\TTRec_Resv\ttrec_resv_pl.sh"
   ```
