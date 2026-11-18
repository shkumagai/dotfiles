#!/usr/bin/env python3

import json
import os
import shlex
import shutil
import sys
from datetime import date
from pathlib import Path
from subprocess import CalledProcessError, check_output
from time import sleep
from typing import Final, Optional


DUMP_DEST_DIR_ROOT: Final = "gh_prs"
"""GitHub の PR をダンプする先のディレクトリのルート"""

PR_FIELDS: Final = [
    "additions",
    "assignees",
    "author",
    "baseRefName",
    "changedFiles",
    "closed",
    "closedAt",
    "closingIssuesReferences",
    "createdAt",
    "deletions",
    "headRefName",
    "isDraft",
    "labels",
    "mergeStateStatus",
    "mergedAt",
    "number",
    "reviewDecision",
    "reviews",
    "state",
    "title",
    "updatedAt",
]
"""GitHub の PR のフィールド。"""

REPO_FIELDS: Final = [
    "archivedAt",
    "createdAt",
    "name",
    "owner",
    "updatedAt",
    "url",
    "sshUrl",
]
"""GitHub の repository のフィールド。"""

org: str = os.environ.get("GH_ORG", "")
"""PR を取得する GitHub の organization (--org または環境変数 GH_ORG)。"""

repositories: list[str] = []
"""GitHub の repository 一覧。"""

target_repositories: Optional[list[str]] = None
"""PR を取得する repository 名の一覧 (--repos-file)。None のときは全 repository (--all)。"""

exclude_archived: bool = False
"""全 repository (--all) のとき、アーカイブ済みの repository を除くかどうか (--no-archived)。"""


def load_repository_names(path: Path) -> list[str]:
    """repository 名の一覧をファイルから読み込む。

    1 行に 1 つの repository 名 (organization なし) を書く。
    `#` から後ろはコメントとして無視し、前後の空白を取り除き、空行は飛ばす。
    重複は最初の 1 つだけを残す。

    Args:
        path: Path 一覧のファイルのパス
    Returns:
        list[str] repository 名の一覧 (ファイルに書かれた順)
    Raises:
        OSError: ファイルを読めない場合
    """
    names: list[str] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        name = line.split("#", 1)[0].strip()
        if name and name not in names:
            names.append(name)
    return names


def get_repositories() -> list[str]:
    """GitHub の repository 一覧を取得する。

    target_repositories が指定されているときは、その中で organization にある
    ものだけに絞る (アーカイブ済みも含む)。無いものは警告を出して飛ばす。
    指定されていないときは全 repository で、exclude_archived が真ならアーカイブ済みを除く。

    Returns:
        list[str] GitHub の repository 一覧
    """
    global repositories

    if not repositories:
        try:
            query_repositories = shlex.split(
                f"gh repo list {org}"
                " --limit 999"
                f" --json {','.join(REPO_FIELDS)}"
                " --jq '.[]|[.name, .archivedAt // \"\"]|@tsv'",
            )
            rows = [
                line.split("\t")
                for line in check_output(query_repositories).decode("utf-8").splitlines()
            ]
            repositories = [
                name for name, archived_at in rows
                if not (exclude_archived and archived_at)
            ]
        except Exception as e:
            _console(f"Error retrieving repositories: {e}\n", stderr=True)
            return repositories

        if target_repositories is not None:
            available = set(repositories)
            for name in target_repositories:
                if name not in available:
                    _console(
                        f"Warning: repository not found; skip: {org}/{name}\n",
                        stderr=True,
                    )
            repositories = [r for r in target_repositories if r in available]

    return repositories


def _console(message: str, newline: bool = False, *, stderr: bool = False) -> None:
    """コンソールにメッセージを出力する。

    Args:
        message: str 出力するメッセージ
        newline: bool メッセージの後に改行を追加するかどうか
        stderr: bool 標準エラー出力に出すかどうか (警告やエラーのとき)
    Returns:
        なし
    """
    if newline:
        message += "\n"
    stream = sys.stderr if stderr else sys.stdout
    stream.write(message)
    stream.flush()


def retrieve_pull_requests_per_day(
    since: str,
    before: str,
    repo: str,
    dest_path: Path,
) -> int:
    """指定された期間に repo でマージされた PR を取得し、JSON ファイルに保存する。

    Args:
        since: 取得する PR のマージ日時の開始日 (例: "2024-01-01")
        before: 取得する PR のマージ日時の終了日 (例: "2024-01-31")
        repo: 取得する PR のリポジトリ名 (例: "dotfiles")
        dest_path: 取得した PR を保存するディレクトリのパス (例: "gh_prs/2024/01/01")
    Returns:
        取得した PR の数
    """
    fields = ",".join(PR_FIELDS)
    query_pull_requests = shlex.split(
        "gh pr list"
        " --state all"
        " --limit 999"
        f" --search \"merged:>={since} merged:<{before}\""
        f" --repo {org}/{repo}"
        f" --json {fields}"
        f" --jq '[.[] | .repository = \"{repo}\"]'",
    )
    try:
        prs = check_output(query_pull_requests).decode("utf-8").strip()
        content = json.loads(prs, strict=False)
        if len(content) == 0:
            return 0

        with open(dest_path / f"prs_{repo}.json", "w") as f:
            f.write(prs)
        return len(content)
    except CalledProcessError as e:
        _console(f"Error retrieving PRs for {repo}: {e}\n", stderr=True)
        return 0


def retrieve_pull_requests_by_repositories(
    since: str,
    before: str,
    *,
    request_interval_sec: float = 1.0,
) -> None:
    """指定された期間にマージされた PR を repository ごとに取得し、JSON ファイルに保存する。

    Args:
        since: 取得する PR のマージ日時の開始日 (例: "2024-01-01")
        before: 取得する PR のマージ日時の終了日 (例: "2024-01-31")
        request_interval_sec: 各リポジトリの PR を取得する間隔 (秒)
    Returns:
        なし
    """
    # retrieve repositories before removing the previous dump
    sorted_repos = sorted(get_repositories())
    if not sorted_repos:
        _console(f"No repositories found; skip {since}\n", stderr=True)
        return

    dest_path = Path(f"{DUMP_DEST_DIR_ROOT}/{since.replace('-', '/')}")
    if dest_path.exists():
        shutil.rmtree(dest_path)
    os.makedirs(dest_path, exist_ok=True)

    summary = []
    for i, repo in enumerate(sorted_repos):
        if i > 0:
            sleep(request_interval_sec)
        _pr_count = retrieve_pull_requests_per_day(
            since,
            before,
            repo,
            dest_path,
        )
        _console("." if _pr_count > 0 else "0")
        summary.append(dict(repo=repo, pr_count=_pr_count))
    _console("\n")

    with open(dest_path / "summary.json", "w") as f:
        json.dump(summary, f, indent=2)


def retrieve_pull_requests_by_ymd(
    start_at: date,
    end_at: date,
    *,
    request_interval_sec: float = 1.0,
    day_interval_sec: float = 5.0,
) -> None:
    """指定された期間にマージされた PR を日付ごとに取得し、JSON ファイルに保存する。

    Args:
        start_at: date  取得する PR のマージ日時の開始日 (例: "2024-01-01")
        end_at: date    取得する PR のマージ日時の終了日 (例: "2024-01-31")
        request_interval_sec: float 各リポジトリの PR を取得する間隔 (秒)
        day_interval_sec: float 各日の PR を取得する間隔 (秒)
    Returns:
        なし
    """
    _console(f"Retrieving PRs for {start_at} to {end_at}", newline=True)
    current_ymd = start_at

    while True:
        _console(f"Retrieving PRs for {current_ymd} ")

        retrieve_pull_requests_by_repositories(
            current_ymd.isoformat(),
            (current_ymd.fromordinal(current_ymd.toordinal() + 1)).isoformat(),
            request_interval_sec=request_interval_sec,
        )
        current_ymd = current_ymd.fromordinal(current_ymd.toordinal() + 1)
        if current_ymd > end_at:
            break
        sleep(day_interval_sec)


def date_type(date_str: str) -> date:
    """コマンドライン引数から日付を受け取るための型変換関数。

    Args:
        date_str: str コマンドライン引数から受け取る日付文字列 (例: "2024-01-01")
    Returns:
        date 変換された日付オブジェクト
    Raises:
        ValueError: 日付文字列の形式が正しくない場合
    """
    try:
        return date.fromisoformat(date_str)
    except ValueError:
        raise ValueError(
            f"Invalid date format: {date_str}. Expected format: YYYY-MM-DD.",
        )


if __name__ == "__main__":
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument(
        "--org",
        help="PR を取得する GitHub の organization (既定: 環境変数 GH_ORG)",
        default=os.environ.get("GH_ORG"),
        required=not os.environ.get("GH_ORG"),
    )
    repos_group = parser.add_mutually_exclusive_group()
    repos_group.add_argument(
        "--repos-file",
        type=lambda p: Path(p).expanduser(),
        help=(
            "PR を取得する repository 名の一覧のファイル。1 行に 1 つ、"
            "# から後ろはコメント (既定: 環境変数 GH_PR_REPOS_FILE)"
        ),
        default=os.environ.get("GH_PR_REPOS_FILE") or None,
    )
    repos_group.add_argument(
        "--all",
        action="store_true",
        help=(
            "organization の全 repository の PR を取得する"
            " (既定ではアーカイブ済みの repository も含む)"
        ),
    )
    parser.add_argument(
        "--no-archived",
        action="store_true",
        help="--all のとき、アーカイブ済みの repository を除く (--all と一緒のときだけ使える)",
    )
    parser.add_argument(
        "-s",
        "--start_at",
        type=date_type,
        help="Pull request の dump の開始日 (例: 2024-01-01)",
        required=True,
    )
    parser.add_argument(
        "-e",
        "--end_at",
        type=date_type,
        help="Pull request の dump の終了日 (例: 2024-01-31)",
        required=False,
        default=date.today(),
    )
    parser.add_argument(
        "--request_interval_sec",
        type=float,
        help="各リポジトリの PR 取得リクエストの間隔 (秒)",
        required=False,
        default=2.5,
    )
    parser.add_argument(
        "--day_interval_sec",
        type=float,
        help="日付毎の PR 取得リクエストの間隔 (秒)",
        required=False,
        default=30.0,
    )

    args = parser.parse_args()
    org = args.org
    exclude_archived = args.no_archived

    if args.no_archived and not args.all:
        parser.error("--no-archived は --all と一緒のときだけ使えます")
    if not args.all:
        if args.repos_file is None:
            parser.error(
                "repository の一覧のファイルを --repos-file か環境変数 GH_PR_REPOS_FILE で"
                "指定してください (全 repository を取得するときは --all)",
            )
        try:
            target_repositories = load_repository_names(args.repos_file)
        except OSError as e:
            parser.error(f"repository の一覧のファイルを読めません: {e}")
        if not target_repositories:
            parser.error(f"repository の一覧のファイルが空です: {args.repos_file}")
        if not get_repositories():
            parser.error(
                f"一覧のどの repository も {org} に見つかりません: {args.repos_file}",
            )

    retrieve_pull_requests_by_ymd(
        start_at=args.start_at,
        end_at=args.end_at,
        request_interval_sec=args.request_interval_sec,
        day_interval_sec=args.day_interval_sec,
    )
