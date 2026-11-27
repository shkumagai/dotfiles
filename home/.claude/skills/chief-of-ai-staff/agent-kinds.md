# エージェントの種類ごとに違うもの（設計メモ）

## このファイルの位置づけ

- 今は、メインのセッションも委任先のセッションも、エージェントは claude（Claude Code）だけを使う。
- このファイルは、将来 codex など別のエージェントを併用するときに読む設計メモ。手順として読ませるものではない。
- 何が・どこに・どう書いてあるかを、軸ごとに整理する。ほかのエージェントでの値は調べていない。すべて「未確認」とし、推測で書かない。
- 用語（エージェント、セッション、セッション名、作業場所、backend）は SKILL.md の「用語と操作」に従う。

## エージェントによって違うもの

「今の置き場所」は、2026-11-27 に grep して確かめた。

| 軸 | Claude Code での今の値 | 今の置き場所 | ほかのエージェント |
|---|---|---|---|
| 起動のコマンドと引数 | herdr の `agent start <セッション名> --kind claude --pane <pane_id>`。claude に渡す引数は `--` のあとに書く | backends/herdr.md「エージェントを起動する」、SKILL.md「操作」の表と「タスクごとのセッション」の手順 2 | 未確認 |
| 入力を受け付けられるようになったことの判定 | herdr の `agent start` が、入力を受け付けられるようになるまで待って返す（`--timeout`） | backends/herdr.md「エージェントを起動する」 | 未確認 |
| 起動時に出る確認の画面 | 信頼済みでないディレクトリで、フォルダを信頼するかの確認で止まる | backends/herdr.md「エージェントを起動する」 | 未確認 |
| 役割の定義の渡し方 | エージェント定義 `~/.claude/agents/<definition>.md` を `--agent` で渡す。困るときは `--append-system-prompt-file` に切り替える | SKILL.md「固定のセッション」、config の `fixed_agents.<役割>.definition`、`~/.claude/agents/tracker-sync.md`・`wiki-writer.md` | 未確認 |
| 役割ごとのツールの制限 | エージェント定義の frontmatter の `disallowedTools`（Agent、Workflow、書き込み先以外の MCP ツール） | `~/.claude/agents/*.md` の frontmatter | 未確認 |
| 全セッション共通の決まりの置き場所 | `~/.claude/CLAUDE.md` の「どのセッションでも守ること」（terraform を実行しない、書き込み先の制限、外部に出る文面） | `~/.claude/CLAUDE.md`。SKILL.md「1. 指示書を書く」「共通の制約」と config の `constraints` のコメントが、そこを参照する | 未確認 |
| 手順書（skill）の読ませ方 | `~/.claude/skills/<名前>/SKILL.md` に置き、Skill ツールで読む | `~/.claude/agents/*.md`「サービスの選び方」、config.example.yaml の `services` のコメント | 未確認 |
| 外部サービスへの接続 | claude.ai のコネクタの MCP（`mcp__claude_ai_*`）。固定のセッションは Atlassian の MCP で Jira・Confluence に書く | `~/.claude/agents/*.md` の `disallowedTools`、サービスごとの skill（jira-writing、confluence-writing のツール名） | 未確認 |
| セッション ID の取り方と再開のコマンド | herdr の `agent list` の `agent_session.value` がセッション ID（`agent` が kind）。再開は `claude --resume <ID>` | どのファイルにも書いていない（grep で該当なし）。`agent_session` は `herdr agent list` の出力で確かめた | 未確認 |
| 状態（作業中・入力待ち・確認待ち）の伝わり方 | herdr が入れた hook `~/.claude/hooks/herdr-agent-state.sh` を、`~/.claude/settings.json` の `SessionStart` から呼ぶ | `~/.claude/settings.json` の `hooks`。skill の中には書いていない | 未確認 |
| 許可の確認・権限のモード | `~/.claude/settings.json` の `permissions.defaultMode: auto` と `deny`・`ask`。許可の確認で止まると herdr の状態が `blocked` になる | `~/.claude/settings.json`、SKILL.md「用語と操作」の「状態」と「3. 終わるのを待つ」、backends/herdr.md「状態を待つ」、`~/.claude/agents/*.md`「守ること」 | 未確認 |
| プロンプトの送り方と文脈の消し方 | herdr の `agent prompt` で送る。文脈を消すときは `/clear` を送る | backends/herdr.md「プロンプトを送る」、SKILL.md「固定のセッション」 | 未確認 |
| 使わない内蔵の委任の仕組み | サブエージェント（Agent ツール）と Workflow | SKILL.md「用語と操作」「進め方の基本」、`~/.claude/agents/*.md` の `disallowedTools`、`~/.claude/CLAUDE.md` の terraform の決まり | 未確認 |
| メインのセッションに chief-of-ai-staff を読ませる方法 | `~/.claude/CLAUDE.md` の「作業の進め方」で skill を指す。skill の description にも「依頼された作業全般で使う」とある | `~/.claude/CLAUDE.md`、SKILL.md の frontmatter | 未確認 |
| 一時ファイルの置き場所 | Claude Code のスクラッチパッド（指示書と報告を置く） | SKILL.md「1. 指示書を書く」、`~/.claude/agents/*.md`「守ること」 | 未確認 |
| 応答の言語とコミットの署名 | `~/.claude/settings.json` の `language: Japanese` と `attribution.commit` | `~/.claude/settings.json` | 未確認 |

## 併用するときに、どこに何を足すか（案）

- **エージェントごとのファイルに分ける**
  - backends/ と同じように、`agent-kinds/<kind>.md` と `agent-kinds/TEMPLATE.md` を作る。
  - 上の表の軸を TEMPLATE.md の欄にし、kind ごとに値と、確かめたコマンドを書く。
  - backends/<backend>.md には、作業場所の操作だけを残す。kind に依る引数（claude の `--agent` など）は、agent-kinds/<kind>.md に移す。
- **config に kind を持たせる**
  - 既定の kind（例: `default_agent_kind: claude`）を足す。
  - 役割ごとの kind（例: `fixed_agents.<役割>.kind`）を足す。`definition` は Claude Code のエージェント定義なので、kind ごとに意味が変わる。kind に合わせた名前のキーにするか、agent-kinds/<kind>.md で読み替えを書く。
  - routines にも、必要なら kind を持たせる。
- **SKILL.md の手順は kind に依らない書き方を保つ**
  - 「エージェントを起動する」の入力の「エージェントの種類」に、config の kind を入れるだけで済むようにする。
  - Claude Code に固有の話（エージェント定義、`/clear`、Skill ツール）は、SKILL.md から agent-kinds/claude.md に移すか、「Claude Code では〜」と明示して残す。
- **共通の決まりを、どのエージェントにも届く場所に置く**
  - 置き場所の案: 共通の決まりのファイルを 1 つにまとめ、エージェントごとの読み込み先からそれを参照する。または、指示書の「守ること」に毎回貼る。

## 注意点

- 共通の決まり（terraform を実行しない、書き込み先の制限、外部に出る文面）は、今は `~/.claude/CLAUDE.md` にしか無い。ほかのエージェントのセッションには届かない。
  - SKILL.md の「1. 指示書を書く」と「共通の制約」は、「委任先のセッションも読むので、指示書に重ねて書かない」としている。ほかのエージェントに任せるときは、この前提が崩れる。指示書に貼り直す必要がある。
- 固定のセッション（wiki、tracker）は、Claude Code のエージェント定義（`--agent`、`disallowedTools`）と、claude.ai のコネクタの MCP に依っている。
  - ほかのエージェントで動かすには、役割の定義、ツールの制限、Jira・Confluence への接続を、そのエージェントの仕組みで作り直す必要がある。
  - ツールの制限が効かないエージェントでは、本文の「守ること」だけが守りになる。
- 状態の伝わり方は、herdr が入れた連携（claude では hook。ファイルに `HERDR_INTEGRATION_ID=claude` とある）に依る。ほかの kind で同じように「確認待ち」を見分けられるかは未確認。
- 手順書の skill は、Skill ツールで読む前提で書いてある。ほかのエージェントでは、ファイルのパスで読ませるなど、読ませ方を決める必要がある。
- メインのセッションをほかのエージェントで動かすときは、chief-of-ai-staff を読ませる仕組みも作り直す必要がある（今は `~/.claude/CLAUDE.md` と skill の description）。
