WITH
  pre1 AS (
    SELECT
      number,
      repository,
      author.login AS author,
      author.is_bot AS is_bot,
      list_max(list_transform(list_filter(reviews,lambda r: r.state == 'APPROVED'), lambda x: x.submittedAt)) AS approved_at_last,
      list_min(list_transform(reviews, lambda x: x.submittedAt)) AS commented_at_first,
      list_transform(assignees, lambda a: a.login) AS assignee_names,
      list_transform(reviews, lambda r: r.author.login) AS reviewer_names,
      additions,
      deletions,
      state,
      createdAt,
      closedAt,
      mergedAt,
      updatedAt
    FROM read_json('gh_prs/2025/*/*/prs_*.json', format='array')
  ),
  pre2 AS (
    SELECT
      pre1.number AS number,
      pre1.repository,
      pre1.author As author,
      pre1.is_bot As is_bot,
      pre1.additions AS additions,
      pre1.deletions AS deletions,
      pre1.state AS state,
      pre1.commented_at_first - pre1.createdAt AS open_to_review_started,
      CASE WHEN pre1.approved_at_last IS NOT NULL
        THEN pre1.approved_at_last - pre1.createdAt
        ELSE NULL END AS open_to_approved,
      pre1.mergedAt - pre1.createdAt AS open_to_merged
    FROM pre1
  ),
  agg AS (
    SELECT
      count(number) AS count,
      sum(epoch_ms(open_to_review_started)) / count(open_to_review_started) AS avg_open_to_review_started,
      sum(epoch_ms(open_to_approved)) / count(open_to_approved) AS avg_open_to_approved,
      sum(epoch_ms(open_to_merged)) / count(open_to_merged) AS avg_open_to_merged
    FROM pre2
  )
SELECT
  pre2.*
FROM pre2
;
