# backend: herdr

SKILL.md の操作を、herdr でどう行うか。SKILL.md の用語との対応と、操作ごとのコマンド、はまりやすい点をまとめる。

## 用語の対応

| SKILL.md の用語 | herdr |
|---|---|
| 作業場所 | workspace |
| 作業場所の識別子 | `workspace_id` |
| 表示名 | workspace の label |
| 起動先 | workspace の root pane の `pane_id` |
| エージェント名 | herdr のエージェント名（`agent start` に渡す名前。`[a-z][a-z0-9_-]{0,31}`） |
| 状態「終わった・入力待ち」 | `done`、`idle` |
| 状態「確認待ち」 | `blocked` |

## 困ったときの参照

- herdr の操作で迷ったら、`herdr --skill` で公式の手順を読む。コマンドの書式は `herdr --help`、`herdr agent` などで確かめる。

## 操作

### 作業場所の一覧を見る

```sh
herdr workspace list
```

- 自分の作業場所の識別子と表示名を、ここで確かめる。

### 作業場所の表示名を付け直す

```sh
herdr workspace rename <workspace_id> <新しい表示名>
```

- 端末を再起動したあと、herdr が前の workspace を label ごと残すことがある。その中でメインのセッションが起動すると、固定のサブエージェントの label が自分の workspace に付いたままになる。SKILL.md の「起動した直後の確認」は、これに備えたもの。

### 作業場所を作る

```sh
# 起動先の pane id は、出力の .result.root_pane.pane_id
herdr workspace create --cwd <作業ディレクトリ> --label <表示名> --no-focus
```

- ID は JSON の出力から取る。一覧の並び順や例から推測しない。

### エージェントを起動する

```sh
# タスクごとのエージェント。準備ができるまで待つ
herdr agent start <エージェント名> --kind claude --pane <pane_id> --timeout 60000
# claude に引数を渡すときは -- のあとに書く（固定のエージェントの --agent など）
herdr agent start <エージェント名> --kind claude --pane <pane_id> --timeout 60000 -- --agent <definition>
```

- `agent start` が成功を返すのは、エージェントが入力を受け付けられるようになってから。
- 起動の途中で確認の画面で止まると、`agent_not_ready` がすぐに返る。名前は残るので、`herdr agent read <エージェント名>` で画面を見る。
  - 信頼済みでないディレクトリで起動すると、Claude Code の確認（このフォルダを信頼するか）で止まる。画面を見て、ユーザーに伝える。勝手に答えない。
- `workspace create` の直後は、シェルの起動が終わっていないことがある。pane がプロンプトに戻っていないと、`agent start` は `agent_pane_busy`（pane is not an available shell）をすぐ返す。
  - `--timeout` が待つのは、起動したエージェントの準備だけ。シェルのプロンプトは待たない。zshrc や starship が遅い回は、数秒かかる。
  - プロンプトが出るまで待ってから `agent start` する。それでも `agent_pane_busy` なら、5 秒おきに再試行し、60 秒で諦める。

```sh
# プロンプトの記号（starship の ❯）が出るまで待つ。60 秒で失敗（終了コード 1）
herdr pane wait-output <pane_id> --match "❯" --timeout 60000
# agent_pane_busy のあいだ、5 秒おきに再試行する（最大 12 回）
for i in $(seq 1 12); do herdr agent start <エージェント名> --kind claude --pane <pane_id> --timeout 60000 >/dev/null 2>&1 && break; sleep 5; done
```

- 再試行のループは出力を捨てるので、終わったら `herdr agent list` で起動したかを確かめる。`agent_not_ready`（確認の画面で止まった）でも再試行が続くので、失敗が続くときは `herdr agent read <エージェント名>` で画面を見る。

### エージェントの一覧を見る

```sh
herdr agent list
```

- 固定のエージェントが生きているかを確かめるのにも、ユーザーに「終わりましたか？」と聞かれたときの確認にも使う。

### プロンプトを送る

```sh
herdr agent prompt <エージェント名> "<文>"
```

- `agent start` が成功する前に prompt を送ると、文字が入力欄に残ったまま送信されない。
  - 確かめるには `herdr agent read <エージェント名>` を使う。
  - 送信されていなければ、もう一度 `agent prompt` を送る。2 回分の文がつながったまま送信されるが、問題はない。
  - `agent send-keys Enter` は auto モードで拒否されることがある。
- `/clear` も、`agent prompt <エージェント名> "/clear"` で送る。
- 確認の画面で止まっているエージェントには、`agent_blocked` が返り、何も送られない。

### 出力を読む

```sh
herdr agent read <エージェント名>
# 確認待ちの中身を見るとき
herdr agent read <エージェント名> --source recent-unwrapped --lines 80
```

### 状態を待つ

報告ファイルができるのを待ってから、エージェントが落ち着くのを待つ。Bash の `run_in_background` で動かす。

```sh
until [ -f <report> ]; do sleep 60; done; herdr agent wait <エージェント名> --until done --until idle --until blocked --timeout 600000
```

- `agent wait` は 10 分ほどでタイムアウトする。そのときは、もう一度待てばよい。
- `blocked` は、許可の確認で止まっているということ。`出力を読む` で中身を見て、ユーザーに伝える。

### 作業場所を閉じる

```sh
herdr workspace close <workspace_id>
```

- 自分が作っていない workspace は、ユーザーに言われない限り閉じない。

### git の worktree を用意する（任意）

- `herdr worktree` を使う。使わないときは、指示書に worktree のパスとブランチ名を書く。
- `--trust-repository` は、ユーザーがリポジトリを確かめてからだけ使う。
