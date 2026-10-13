# calendar_tool

Google Calendar API v3 にイベントを登録するスクリプト群。依存は各スクリプトの PEP 723 メタデータで宣言しているので `uv` があれば直接実行できる。

| ファイル | 役割 |
|---|---|
| `gcalendar.py` | OAuth 認証とイベント登録の共通モジュール。直接実行するとカレンダー ID 一覧を表示 |
| `TowerInstoreEvent.py` | タワーレコードのインストアイベントを取得 |
| `tower_event_to_google_calendar.py` | 上記イベントをカレンダーへ登録 |
| `boyscout.py` | ボーイスカウトの予定を登録 |

## Setup

1. Google Cloud Console で Calendar API を有効化し、OAuth クライアント ID（デスクトップアプリ）を作成する
2. ダウンロードした JSON を `~/.config/calendar_tool/credentials.json` に置く（`CALENDAR_TOOL_CONFIG_DIR` で変更可）
3. `./gcalendar.py` を実行してブラウザで認可する。トークンは同じディレクトリの `token.json` に保存され、カレンダー ID 一覧が表示される

## Usage

```sh
TOWER_CALENDAR_ID=primary ./tower_event_to_google_calendar.py
BOYSCOUT_CALENDAR_ID=xxxx@group.calendar.google.com ./boyscout.py
```
