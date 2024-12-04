-- 2. Which bowlers have the best performance throughout the tournament?
-- Create a temporary table to filter out invalid deliveries (e.g., wides)
WITH valid_balls AS (
    SELECT
        bowler,
        COUNT(*) AS balls_bowled
    FROM
        player_performance
    WHERE
        extras_type != 'wides' OR extras_type IS NULL
    GROUP BY
        bowler
),
bowler_runs AS (
    SELECT
        bowler,
        SUM(total_runs) AS runs_conceded
    FROM
        player_performance
    GROUP BY
        bowler
),
bowler_wickets AS (
    SELECT
        bowler,
        COUNT(*) AS wickets
    FROM
        player_performance
    WHERE
        is_wicket = 1
    GROUP BY
        bowler
),
bowler_performance AS (
    SELECT
        vb.bowler,
        vb.balls_bowled,
        br.runs_conceded,
        COALESCE(bw.wickets, 0) AS wickets,
        CAST(vb.balls_bowled / 6 AS FLOAT) + CAST(vb.balls_bowled % 6 AS FLOAT) / 6 AS overs_bowled,
        CAST(br.runs_conceded AS FLOAT) / (CAST(vb.balls_bowled / 6 AS FLOAT) + CAST(vb.balls_bowled % 6 AS FLOAT) / 6) AS economy_rate
    FROM
        valid_balls vb
    JOIN
        bowler_runs br ON vb.bowler = br.bowler
    LEFT JOIN
        bowler_wickets bw ON vb.bowler = bw.bowler
)
SELECT
    bowler,
    balls_bowled,
    runs_conceded,
    wickets,
    overs_bowled,
    economy_rate
FROM
    bowler_performance
ORDER BY
    wickets DESC,
    economy_rate ASC;

