SELECT
  groups.draw_id AS draw_id,
  groups.clip_id AS clip_id,
  groups.id AS group_id
FROM groups

WHERE groups.clip_id IS NULL

UNION

SELECT DISTINCT ON
  (groups.clip_id)
  groups.draw_id AS draw_id,
  groups.clip_id AS clip_id,
  NULL AS group_id
FROM groups

WHERE groups.clip_id IS NOT NULL
