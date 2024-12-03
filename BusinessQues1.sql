-- 1. Which players have the best batting performance across all matches?
-- Calculate total runs, dismissals, balls faced, batting average, and strike rate
WITH batter_runs AS (
    SELECT
        batter AS player,
        SUM(batsman_runs) AS total_runs
    FROM
        player_performance
    GROUP BY
        batter
),
batter_dismissals AS (
    SELECT
        player_dismissed AS player,
        COUNT(*) AS dismissals
    FROM
        player_performance
    WHERE
        player_dismissed IS NOT NULL
    GROUP BY
        player_dismissed
),
balls_faced AS (
    SELECT
        batter AS player,
        COUNT(*) AS balls_faced
    FROM
        player_performance
    WHERE
        extras_type != 'wides' OR extras_type IS NULL
    GROUP BY
        batter
),
batting_performance AS (
    SELECT
        br.player,
        br.total_runs,
        COALESCE(bd.dismissals, 0) AS dismissals,
        COALESCE(bf.balls_faced, 0) AS balls_faced,
        CASE
            WHEN COALESCE(bd.dismissals, 0) = 0 THEN NULL
            ELSE br.total_runs / bd.dismissals
        END AS batting_average,
        CASE
            WHEN COALESCE(bf.balls_faced, 0) = 0 THEN NULL
            ELSE (br.total_runs / bf.balls_faced) * 100
        END AS strike_rate
    FROM
        batter_runs br
    LEFT JOIN
        batter_dismissals bd ON br.player = bd.player
    LEFT JOIN
        balls_faced bf ON br.player = bf.player
)
SELECT
    player,
    total_runs,
    dismissals,
    balls_faced,
    batting_average,
    strike_rate
FROM
    batting_performance
ORDER BY
    total_runs DESC,
    batting_average DESC,
    strike_rate DESC;