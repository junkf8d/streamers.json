# streamers.json

- ストリーマー、VTuberのリンクをjsonでまとめたいリポジトリ
    - 最終的にはリポジトリ直下の `streamers.json`を参照する
- Youtubeから情報をもってくるサイト作りたくてそれの初期データ用に作った

# スクレイピング

- `src/scrapers`は公式サイトのパーサー
    - サイト側の変更ですぐ使えなくなるのでメンテナンスはあまり考えない
    - サーバー負荷を考慮
        - 通信するごとに数秒あける
        - 一度取得したら次からはキャッシュを使用し取得しない
            - キャッシュを使いたくない場合は`cache`フォルダかその中の特定ファイルを削除する
        - 各サイトの`robots.txt`は特に問題ないこと確認済み
    - usage: `rake -T`
        - `rake build`ですべて実行し `streamers.json`を生成する
        - 一つずつ実行したい場合は `ruby src/scraper/foo.rb`を直接実行

# 取得する情報

- にじさんじ: https://www.nijisanji.jp/talents
- ホロライブ: https://hololive.hololivepro.com/talents/
- ぶいすぽ: https://vspo.jp/member/
- ZETA DIVISION: https://zetadivision.com/members
- RIDDLE: https://riddle.info/members/

他は未定

# 備考

- 公式サイトから拾ってるが限界があるので、最終的には手動で追加する必要がある
    - どうするかは考えてない
    - てかGoogle Spreadsheetのがよくねとは少し思う
- **問題あればすぐ削除します**
    - https://x.com/junkf8d まで