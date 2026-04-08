#!/usr/bin/env python

import json
import os
import shlex
import shutil
import sys
from datetime import date
from pathlib import Path
from subprocess import CalledProcessError, check_output
from time import sleep
from typing import Final


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

query_repositories: Final = shlex.split(
    "gh repo list visasq"
    " --limit 999"
    " --no-archived"
    f" --json {','.join(REPO_FIELDS)}"
    " --jq '.[]|.name'",
)
"""GitHub の repository 一覧を取得するためのコマンド。"""

repositories: list[str] = []
"""GitHub の repository 一覧。"""


def get_repositories():
    """GitHub の repository 一覧を取得する。

    Returns:
        list[str] GitHub の repository 一覧
    """
    global repositories

    if not repositories:
        try:
            repositories = check_output(query_repositories).decode("utf-8").splitlines()
        except Exception as e:
            _console(f"Error retrieving repositories: {e}\n")

    return repositories


def _console(message: str, newline: bool = False) -> None:
    """コンソールにメッセージを出力する。

    Args:
        message: str 出力するメッセージ
        newline: bool メッセージの後に改行を追加するかどうか
    Returns:
        なし
    """
    if newline:
        message += "\n"
    sys.stdout.write(message)
    sys.stdout.flush()


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
        f" --repo visasq/{repo}"
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
        _console(f"Error retrieving PRs for {repo}: {e}\n")
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
    dest_path = Path(f"{DUMP_DEST_DIR_ROOT}/{since.replace('-', '/')}")
    if dest_path.exists():
        shutil.rmtree(dest_path)
    os.makedirs(dest_path, exist_ok=True)

    summary = []
    sorted_repos = sorted(get_repositories())
    while True:
        repo = sorted_repos.pop(0)
        _pr_count = retrieve_pull_requests_per_day(
            since,
            before,
            repo,
            dest_path,
        )
        _console("." if _pr_count > 0 else "0")
        summary.append(dict(repo=repo, pr_count=_pr_count))

        if len(sorted_repos) == 0:
            break
        sleep(request_interval_sec)
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

    retrieve_pull_requests_by_ymd(
        start_at=args.start_at,
        end_at=args.end_at,
        request_interval_sec=args.request_interval_sec,
        day_interval_sec=args.day_interval_sec,
    )
