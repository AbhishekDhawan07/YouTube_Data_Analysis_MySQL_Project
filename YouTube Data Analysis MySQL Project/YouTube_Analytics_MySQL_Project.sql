CREATE DATABASE YouTube;
USE YouTube;
DROP TABLE creators;
select * from creators_dataset;
select * from videos_dataset ;
select * from daily_views_dataset;
select * from comments_dataset_youtube_analytics_project;
select * from likes_dislikes_Youtube_data_analytics_dataset;
select * from revenue_dataset_YouTube_Data_Analytics_Project;

-- Basic MySQL Queries(1-10). 
-- 1. List all videos and their creator names.


SELECT 
    v.video_id,
    v.title,
    c.creator_name
FROM videos_dataset v
INNER JOIN creators_dataset c 
    ON c.creator_id = v.creator_id;
    
-- 2. Count total videos per creator.

SELECT 
    c.creator_name,
    COUNT(v.video_id) AS Count_Videos_per_Creator
FROM videos_dataset v
INNER JOIN creators_dataset c 
    ON c.creator_id = v.creator_id
GROUP BY c.creator_name;

-- 3. Get total comments for a given video.
select v.video_id,SUM(comment_id) as Total_Comments from videos_dataset v inner join comments_dataset_youtube_analytics_project c on c.video_id=v.video_id
group by v.video_id;

-- 4. List videos published in the last 36 months.

SELECT video_id, title, publish_date
FROM videos_dataset
WHERE publish_date >= DATE_SUB(CURDATE(), INTERVAL 36 MONTH)
ORDER BY publish_date DESC;

-- 5. Find videos longer than 20 minutes.

select * from videos_dataset where duration_seconds>20*60;



-- 6. Show top 10 videos by total views (aggregate daily_views).



SELECT video_id, SUM(views) AS TotalViews
FROM daily_views_dataset
GROUP BY video_id
ORDER BY TotalViews DESC
LIMIT 10;

-- 7. Show unique categories.

select distinct category from videos_dataset ;


-- 8. Count creators per country.

select country,COUNT(creator_id) Number_Of_Creators from creators_dataset group by country;


-- 9. Get average views per video per creator.

SELECT c.creator_name, v.video_id, AVG(d.views) AS AVG_VIEWS
FROM daily_views_dataset d
INNER JOIN videos_dataset v ON v.video_id = d.video_id
INNER JOIN creators_dataset c ON c.creator_id = v.creator_id
GROUP BY c.creator_name, v.video_id;


-- 10. Find videos with zero comments.

SELECT video_id
FROM videos_dataset
WHERE video_id NOT IN (
    SELECT video_id FROM comments_dataset_youtube_analytics_project
);



-- Filters & Aggregates(11–20).

-- 11. Total impressions and clicks per video.


select title,SUM(impressions) Total_impressions, SUM(clicks) as Total_Clicks
from daily_views_dataset dv inner join videos_dataset v on v.video_id=dv.video_id
group by title;

 -- 12. Compute CTR = clicks / impressions per day.
 
select view_date,round(cast(SUM(clicks) as float)/SUM(impressions),2)*100 CTR
from daily_views_dataset 
group by view_date
having SUM(impressions)>0;

 -- 13. Average watch time per view(watch_time_seconds / views).
 
SELECT video_id, watch_time_seconds / views AS avg_watch_time_per_view
FROM daily_views_dataset;


 -- 14. Daily views trend for a single video.
 
SELECT video_id, view_date, views
FROM daily_views_dataset
WHERE video_id = 1147
ORDER BY view_date;

 -- 15. Views per category.
select category,AVG(views) as TotalViews from daily_views_dataset dv
inner join  videos_dataset v
on v.video_id=dv.video_id
group by category;

 -- 16. Top 5 videos by watch_time_seconds.
WITH cte AS (
    SELECT video_id,
           SUM(watch_time_seconds) AS total_watch_time
    FROM daily_views_dataset
    GROUP BY video_id
)
SELECT v.title
FROM (
    SELECT video_id,
           ROW_NUMBER() OVER (ORDER BY total_watch_time DESC) AS rn
    FROM cte
) c
JOIN videos_dataset v ON v.video_id = c.video_id
WHERE rn <= 10;


 -- 17. Average likes/dislikes per video.
SELECT VIDEO_ID,AVG(LIKES) AS AVG_LIKES,AVG(DISLIKES) AS AVG_DISLIKES  FROM likes_dislikes_Youtube_data_analytics_dataset
GROUP BY video_id;

 -- 18. List videos with more dislikes than likes.
 select * from(
SELECT video_id,case when SUM(LIKES)> SUM(DISLIKES) then 1 else 0 end as Like_Dislike_flag
FROM likes_dislikes_YouTube_data_analytics_dataset group by video_id) a
where like_dislike_flag=0;

 -- 19. Videos where avg_view_duration < 20% of duration.
 
 SELECT dv.video_id,
       AVG(avg_view_duration_seconds) AS Avg_watch_duration,
       0.2 * v.duration_seconds AS Duration_20
FROM daily_views_dataset dv
INNER JOIN videos_dataset v 
ON v.video_id = dv.video_id
GROUP BY dv.video_id, v.duration_seconds
HAVING AVG(avg_view_duration_seconds) < 0.2 * v.duration_seconds;

-- 20. Videos that gained more than 1k views in a day (spikes).
select view_date,video_id from daily_views_dataset where views>1000;


-- Joins & Multi-table(21–30):

--  21. For each creator, total revenue(ad + subscription + other).
select c.creator_name,sum(ad_revenue+sponsorship_revenue+membership_revenue) AS TotalRevenue
from revenue_dataset_YouTube_Data_Analytics_Project r
inner join videos_dataset v 
on r.video_id=v.video_id
inner join
creators_dataset c on
c.creator_id=v.creator_id
group by c.creator_id,creator_name;

-- 22. For each video, last 7-day rolling average views.

select video_id,view_date,views,AVG(views) over(partition by video_id order by view_date
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 7_Day_Rolling_Average_Views
from daily_views_dataset
ORDER BY video_id,view_date;

--  23. Top performing video per creator by revenue.

WITH video_revenue AS (
    SELECT v.creator_id,
           dv.video_id,
           SUM(dv.views) AS total_views
    FROM daily_views_dataset dv
    JOIN videos_dataset v 
        ON v.video_id = dv.video_id
    GROUP BY v.creator_id, dv.video_id
),
ranked_videos AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY creator_id 
                             ORDER BY total_views DESC) AS rn
    FROM video_revenue
)
SELECT creator_id, video_id, total_views
FROM ranked_videos
WHERE rn = 1;

-- 24. Video comment sentiment breakdown(pos/neutral/neg


SELECT video_id,
       SUM(CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_comments,
       SUM(CASE WHEN sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral_comments,
       SUM(CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_comments
FROM comments_dataset_youtube_analytics_project
GROUP BY video_id;

-- 25. Videos with impressions but 0 clicks(possible data issue).

select * from daily_views_dataset where impressions=0;

--  26. List videos and their peak daily views date.

SELECT d.video_id,
       d.view_date,
       m.max_views
FROM daily_views_dataset d
JOIN (
    SELECT video_id, MAX(views) AS max_views
    FROM daily_views_dataset
    GROUP BY video_id
) m 
ON d.video_id = m.video_id
AND d.views = m.max_views;

--  27. Show creators who published > 10 videos.
select creator_name
from videos_dataset v inner join creators_dataset c on c.creator_id=v.creator_id
group by c.creator_name
having COUNT(v.video_id)>10;

-- 28. Videos with multiple high-spike days.

-- 1k views in a day is a high spike day

select distinct video_id from daily_views_dataset
where views>1000
group by video_id
having COUNT(*)>1;

-- 29. Find videos with payments revenue but zero views(data mismatch).

SELECT DISTINCT video_id
FROM revenue_dataset_YouTube_Data_Analytics_Project
WHERE video_id NOT IN (
    SELECT DISTINCT video_id
    FROM daily_views_dataset
);

-- 30. Creator-wise average CTR.
-- CTR = clicks/impressions

SELECT c.creator_name,
       AVG(clicks * 1.0 / impressions) AS CTR
FROM daily_views_dataset dv
JOIN videos_dataset v 
     ON v.video_id = dv.video_id
JOIN creators_dataset c 
     ON c.creator_id = v.creator_id
WHERE impressions > 0
GROUP BY c.creator_name;


-- Window Functions & Ranking(31–39):

-- 31. Rank videos by total views within each category(RANK/DENSE_RANK).

WITH cte AS (
    SELECT dv.video_id,
           v.title,
           v.category,
           SUM(dv.views) AS total_views
    FROM daily_views_dataset dv
    JOIN videos_dataset v 
         ON v.video_id = dv.video_id
    GROUP BY dv.video_id, v.title, v.category
)
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_views DESC) AS rn
FROM cte;

-- 32. Running total of views per video(window).

SELECT *,
       SUM(views) OVER (
           PARTITION BY video_id
           ORDER BY view_date
       ) AS Running_Total_Views
FROM daily_views_dataset;

-- 33. Monthly growth rate of views for each video(LAG).

WITH cte AS (
    SELECT video_id,
           MONTH(view_date) AS mnth,
           SUM(views) AS views
    FROM daily_views_dataset
    GROUP BY video_id, MONTH(view_date)
),
cte1 AS (
    SELECT *,
           LAG(views) OVER (
               PARTITION BY video_id
               ORDER BY mnth
           ) AS Prev_Mnth_views
    FROM cte
)
SELECT video_id,
       mnth,
       views,
       Prev_Mnth_views,
       ((views - Prev_Mnth_views) / Prev_Mnth_views) * 100 AS growth_rate
FROM cte1;

--  34. Top 3 videos per month(window + partition).

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY MONTH(view_date)
               ORDER BY views DESC
           ) AS rn
    FROM daily_views_dataset
) a
WHERE rn <= 3;

-- 35. Percentile of views for each video(NTILE).
SELECT
    dv.video_id,
    v.title,
    dv.view_date,
    dv.views,
    NTILE(10) OVER (
        PARTITION BY dv.video_id
        ORDER BY dv.views
    ) AS view_percentile
FROM daily_views_dataset dv
JOIN videos_dataset v
    ON dv.video_id = v.video_id
ORDER BY dv.video_id, dv.view_date;

-- 36. Lead/Lag to calculate day-over-day % change.

WITH cte AS (
    SELECT *,
           LAG(views) OVER (
               PARTITION BY video_id 
               ORDER BY view_date
           ) AS Prev_day_views
    FROM daily_views_dataset
)
SELECT *,
       ((views - Prev_day_views) / NULLIF(Prev_day_views,0)) * 100 
       AS Growth_percentage
FROM cte;

-- 37. Cumulative watch time per creator.

SELECT 
    c.creator_id,
    dv.video_id,
    dv.view_date,
    SUM(dv.watch_time_seconds) OVER (
        PARTITION BY c.creator_id
        ORDER BY dv.view_date
    ) AS Cumulative_sum
FROM daily_views_dataset dv
JOIN videos_dataset v 
     ON v.video_id = dv.video_id
JOIN creators_dataset c 
     ON c.creator_id = v.creator_id;

-- 38. Rank creators by average watch time per video.

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY c.creator_name 
           ORDER BY dv.avg_view_duration_seconds
       ) AS rn
FROM daily_views_dataset dv
JOIN videos_dataset v 
     ON v.video_id = dv.video_id
JOIN creators_dataset c 
     ON c.creator_id = v.creator_id;

-- 39. Use ROW_NUMBER to deduplicate and get latest daily_stats.

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY video_id, view_date
               ORDER BY view_date DESC
           ) AS rn
    FROM daily_views_dataset
)
SELECT *
FROM cte
WHERE rn = 1;

-- Advanced / Analytics(41–50):

-- 40. Compute engagement score = (likes + comments + clicks) / impressions.

WITH agg AS (
    SELECT
        v.video_id,
        SUM(ld.likes) AS total_likes,
        SUM(dv.clicks) AS total_clicks,
        (SELECT COUNT(*) 
         FROM comments_dataset_youtube_analytics_project c 
         WHERE c.video_id = v.video_id) AS total_comments,
        SUM(dv.impressions) AS total_impressions
    FROM videos_dataset v
    LEFT JOIN likes_dislikes_Youtube_data_analytics_dataset ld 
        ON ld.video_id = v.video_id
    LEFT JOIN daily_views_dataset dv 
        ON dv.video_id = v.video_id
    GROUP BY v.video_id
)

SELECT
    video_id,
    total_likes,
    total_comments,
    total_clicks,
    total_impressions,
    CASE 
        WHEN total_impressions = 0 THEN NULL
        ELSE (total_likes + total_comments + total_clicks) * 1.0 / total_impressions
    END AS engagement_score
FROM agg
ORDER BY engagement_score DESC;

-- 41. Detect anomaly days using z-score on daily views.

WITH stats AS (
    SELECT
        video_id,
        AVG(views) AS mean_views,
        STDDEV(views) AS stddev_views
    FROM daily_views_dataset
    GROUP BY video_id
)
SELECT
    dv.video_id,
    dv.view_date,
    dv.views,
    CASE 
        WHEN s.stddev_views = 0 THEN 0
        ELSE (dv.views - s.mean_views) / s.stddev_views
    END AS z_score
FROM daily_views_dataset dv
JOIN stats s 
    ON dv.video_id = s.video_id
ORDER BY dv.video_id, dv.view_date;

-- 42. Calculate creator retention: percent of videos still getting views after 90 days.

WITH last_view AS (
    SELECT
        video_id,
        MAX(view_date) AS last_view_date
    FROM daily_views_dataset
    GROUP BY video_id
),
video_age AS (
    SELECT
        v.video_id,
        v.creator_id,
        lv.last_view_date,
        DATEDIFF(lv.last_view_date, v.publish_date) AS days_active
    FROM videos_dataset v
    JOIN last_view lv 
        ON lv.video_id = v.video_id
)
SELECT
    c.creator_id,
    c.creator_name,
    COUNT(CASE WHEN va.days_active >= 90 THEN 1 END) * 1.0 / COUNT(*) AS retention_ratio
FROM video_age va
JOIN creators_dataset c 
    ON c.creator_id = va.creator_id
GROUP BY c.creator_id, c.creator_name
ORDER BY retention_ratio DESC;

-- 43. Find videos that cause highest drop-off (avg_view_duration << duration).

WITH agg AS (
    SELECT
        v.video_id,
        v.title,
        v.duration_seconds,
        AVG(dv.avg_view_duration_seconds) AS avg_watch
    FROM videos_dataset v
    JOIN daily_views_dataset dv 
        ON dv.video_id = v.video_id
    GROUP BY v.video_id, v.title, v.duration_seconds
)
SELECT
    video_id,
    title,
    duration_seconds,
    avg_watch,
    avg_watch / NULLIF(duration_seconds,0) AS drop_off_ratio
FROM agg
ORDER BY drop_off_ratio ASC;


-- 44. Customer lifetime value style: total revenue per creator normalized by number of videos.
WITH revenue_sum AS (
    SELECT
        v.creator_id,
        SUM(
            COALESCE(r.ad_revenue,0) +
            COALESCE(r.membership_revenue,0) +
            COALESCE(r.sponsorship_revenue,0)
        ) AS total_revenue
    FROM videos_dataset v
    LEFT JOIN revenue_dataset_YouTube_Data_Analytics_Project r
        ON r.video_id = v.video_id
    GROUP BY v.creator_id
),

video_count AS (
    SELECT
        creator_id,
        COUNT(*) AS num_videos
    FROM videos_dataset
    GROUP BY creator_id
)

SELECT
    c.creator_id,
    c.creator_name,
    rs.total_revenue,
    vc.num_videos,
    rs.total_revenue / NULLIF(vc.num_videos,0) AS revenue_per_video
FROM revenue_sum rs
JOIN video_count vc 
    ON vc.creator_id = rs.creator_id
JOIN creators_dataset c 
    ON c.creator_id = rs.creator_id
ORDER BY revenue_per_video DESC;


--  45. Segment videos into bins by length and analyze average CTR per bin.
 -- Bins logic is as: 
 -- WHEN duration_seconds < 300 THEN 'Short (<5 min)'
 -- WHEN duration_seconds < 1200 THEN 'Medium (5–20 min)'
 -- ELSE 'Long (>20 min)'
 
 WITH len_bins AS (
    SELECT
        video_id,
        CASE 
            WHEN duration_seconds < 300 THEN 'Short (<5 min)'
            WHEN duration_seconds < 1200 THEN 'Medium (5–20 min)'
            ELSE 'Long (>20 min)'
        END AS length_bin
    FROM videos_dataset
),

ctr AS (
    SELECT
        dv.video_id,
        SUM(dv.clicks) AS total_clicks,
        SUM(dv.impressions) AS total_impressions
    FROM daily_views_dataset dv
    GROUP BY dv.video_id
)

SELECT
    lb.length_bin,
    AVG(
        CASE 
            WHEN c.total_impressions = 0 THEN NULL
            ELSE c.total_clicks * 1.0 / c.total_impressions 
        END
    ) AS avg_ctr
FROM len_bins lb
JOIN ctr c 
    ON c.video_id = lb.video_id
GROUP BY lb.length_bin
ORDER BY avg_ctr DESC;

--  46. Identify top comments contributors(who comments most).
SELECT
    author,
    COUNT(*) AS total_comments
FROM comments_dataset_youtube_analytics_project
GROUP BY author
ORDER BY total_comments DESC;

    
    
-- 47. Find out videos which had more than 20k impressions but no revenue.
SELECT
    dv.video_id,
    SUM(dv.impressions) AS total_impressions,
    SUM(
        COALESCE(r.ad_revenue,0) +
        COALESCE(r.membership_revenue,0) +
        COALESCE(r.sponsorship_revenue,0)
    ) AS total_revenue
FROM daily_views_dataset dv
LEFT JOIN revenue_dataset_youtube_data_analytics_project r
    ON r.video_id = dv.video_id
GROUP BY dv.video_id
HAVING SUM(dv.impressions) > 20000
AND SUM(
        COALESCE(r.ad_revenue,0) +
        COALESCE(r.membership_revenue,0) +
        COALESCE(r.sponsorship_revenue,0)
    ) = 0;


-- 48. Build a pivot: monthly revenue by category.

SELECT
    v.category,

    SUM(CASE WHEN DATE_FORMAT(r.date,'%Y-%m')='2023-01' 
        THEN r.ad_revenue + r.membership_revenue + r.sponsorship_revenue END) AS `2023-01`,

    SUM(CASE WHEN DATE_FORMAT(r.date,'%Y-%m')='2023-02' 
        THEN r.ad_revenue + r.membership_revenue + r.sponsorship_revenue END) AS `2023-02`,

    SUM(CASE WHEN DATE_FORMAT(r.date,'%Y-%m')='2023-03' 
        THEN r.ad_revenue + r.membership_revenue + r.sponsorship_revenue END) AS `2023-03`,

    SUM(CASE WHEN DATE_FORMAT(r.date,'%Y-%m')='2023-04' 
        THEN r.ad_revenue + r.membership_revenue + r.sponsorship_revenue END) AS `2023-04`,

    SUM(CASE WHEN DATE_FORMAT(r.date,'%Y-%m')='2023-05' 
        THEN r.ad_revenue + r.membership_revenue + r.sponsorship_revenue END) AS `2023-05`,

    SUM(CASE WHEN DATE_FORMAT(r.date,'%Y-%m')='2023-06' 
        THEN r.ad_revenue + r.membership_revenue + r.sponsorship_revenue END) AS `2023-06`

FROM revenue_dataset_youtube_data_analytics_project r
JOIN videos_dataset v 
    ON v.video_id = r.video_id
GROUP BY v.category;

--  49. Multi-day conversion funnel: impressions → clicks → views → watch_time(aggregate ratios).

SELECT
    video_id,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(views) AS views,
    SUM(watch_time_seconds) AS watch_time,
    CASE 
        WHEN SUM(impressions)=0 THEN NULL 
        ELSE SUM(clicks)*1.0/SUM(impressions) 
    END AS ctr,
    CASE 
        WHEN SUM(clicks)=0 THEN NULL 
        ELSE SUM(views)*1.0/SUM(clicks) 
    END AS click_to_view
FROM daily_views_dataset
GROUP BY video_id
ORDER BY video_id;

--  50. Mark videos with inconsistent data(daily_views exists but no likes_dislikes for that day).

-- (daily_views exists but no likes_dislikes for that day).

SELECT
    dv.video_id,
    dv.view_date,
    dv.views,
    ld.id AS likes_record_missing_flag
FROM daily_views_dataset dv
LEFT JOIN likes_dislikes_youtube_data_analytics_dataset ld
    ON ld.video_id = dv.video_id
   AND ld.date = dv.view_date
WHERE ld.id IS NULL
ORDER BY dv.video_id, dv.view_date;

