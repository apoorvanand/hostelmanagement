(
  SELECT
    clips.draw_id AS draw_id,
    clips.id AS clip_id,
    NULL AS group_id
  FROM
    clips
)

UNION

(
  SELECT
    groups.draw_id AS draw_id,
    NULL AS clip_id,
    groups.id AS group_id
  FROM
    groups AS groups

  NATURAL LEFT OUTER JOIN

  (
    SELECT
      clip_memberships.group_id AS group_id,
      clip_memberships.confirmed AS confirmed
    FROM
      clip_memberships
    WHERE
      clip_memberships.confirmed
  ) AS clip_memberships

  WHERE
    groups.clip_membership_id IS NULL
  OR 
    clip_memberships.confirmed
)
