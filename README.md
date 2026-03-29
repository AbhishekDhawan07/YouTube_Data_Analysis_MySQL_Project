# 🎬 YouTube Data Analysis MySQL Project

A structured SQL analytics project built on a simulated YouTube dataset. This project covers the full spectrum of MySQL querying - from basic `SELECT` statements to advanced window functions, CTEs, anomaly detection, and revenue analytics - across six relational tables.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Database Schema](#database-schema)
4. [Dataset Description](#dataset-description)
5. [Query Categories](#query-categories)
6. [Tech Stack](#tech-stack)
7. [Project Structure](#project-structure)
8. [Getting Started](#getting-started)
9. [Sample Queries](#sample-queries)
10. [Key Insights Unlocked](#key-insights-unlocked)
11. [Author](#author)
12. [Contributing](#contributing)

---

## Project Overview

This project simulates a YouTube-like analytics platform using MySQL. It models the relationships between creators, videos, daily performance metrics, audience engagement (likes/dislikes, comments), and revenue streams.

The goal is to practice and demonstrate real-world SQL skills - from simple data retrieval to complex multi-table joins, window functions, Z-score anomaly detection, and KPI computation like CTR, engagement score, and creator lifetime value.

---

## Features

- **50 SQL queries** spanning five difficulty tiers
- Multi-table `JOIN` operations across 6 normalized tables
- **Window functions**: `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `NTILE`, `SUM OVER`, `AVG OVER`
- **CTEs** for readable, modular query design
- Engagement scoring formula: `(likes + comments + clicks) / impressions`
- **Z-score anomaly detection** on daily view counts
- Revenue analytics: per-creator totals, per-video normalization, revenue-per-video KPI
- Conversion funnel analysis: impressions → clicks → views → watch time
- Sentiment breakdown of comments (positive / neutral / negative)
- Content drop-off detection based on average view duration vs. video length
- Monthly revenue pivot by video category
- Data quality checks: revenue with zero views, daily views with no matching likes records

---

## Database Schema

```
creators_dataset
    └── creator_id (PK)
    └── creator_name
    └── channel_name
    └── country
    └── join_date

videos_dataset
    └── video_id (PK)
    └── creator_id (FK → creators_dataset)
    └── title
    └── publish_date
    └── duration_seconds
    └── category

daily_views_dataset
    └── view_id (PK)
    └── video_id (FK → videos_dataset)
    └── view_date
    └── views
    └── watch_time_seconds
    └── avg_view_duration_seconds
    └── impressions
    └── clicks

likes_dislikes_Youtube_data_analytics_dataset
    └── id (PK)
    └── video_id (FK → videos_dataset)
    └── date
    └── likes
    └── dislikes

comments_dataset_youtube_analytics_project
    └── comment_id (PK)
    └── video_id (FK → videos_dataset)
    └── author
    └── date
    └── sentiment

revenue_dataset_YouTube_Data_Analytics_Project
    └── id (PK)
    └── video_id (FK → videos_dataset)
    └── date
    └── ad_revenue
    └── sponsorship_revenue
    └── membership_revenue
```

---

## Dataset Description

| File | Description | Key Columns |
|---|---|---|
| `creators_dataset.csv` | YouTube creator profiles | `creator_id`, `creator_name`, `channel_name`, `country`, `join_date` |
| `videos_dataset.csv` | Video metadata | `video_id`, `creator_id`, `title`, `publish_date`, `duration_seconds`, `category` |
| `daily_views_dataset.csv` | Daily performance per video | `video_id`, `view_date`, `views`, `watch_time_seconds`, `impressions`, `clicks` |
| `likes_dislikes_Youtube_data_analytics_dataset.csv` | Daily like/dislike counts | `video_id`, `date`, `likes`, `dislikes` |
| `comments_dataset_youtube_analytics_project.csv` | Video comments with sentiment | `video_id`, `author`, `date`, `sentiment` |
| `revenue_dataset_YouTube_Data_Analytics_Project.csv` | Revenue by type per video | `video_id`, `date`, `ad_revenue`, `sponsorship_revenue`, `membership_revenue` |

---

## Query Categories

### 🟢 Basic Queries (1–10)
Foundational SQL: selecting, filtering, joining, and grouping.

- List all videos with their creator names
- Count total videos per creator
- Get total comments per video
- List videos published in the last 36 months
- Find videos longer than 20 minutes
- Top 10 videos by total views
- Show unique video categories
- Count creators per country
- Average views per video per creator
- Find videos with zero comments

---

### 🔵 Filters & Aggregates (11–20)
Intermediate aggregation, date math, and conditional logic.

- Total impressions and clicks per video
- Compute CTR (clicks / impressions) per day
- Average watch time per view
- Daily views trend for a specific video
- Views per content category
- Top 5 videos by total watch time (via CTE)
- Average likes and dislikes per video
- Videos where dislikes exceed likes
- Videos where avg view duration is below 20% of total length
- Daily view spike detection (views > 1,000)

---

### 🟡 Joins & Multi-Table (21–30)
Cross-table analysis combining multiple datasets.

- Total revenue (ad + sponsorship + membership) per creator
- 7-day rolling average views per video (window function)
- Top performing video per creator by revenue (CTE + ROW_NUMBER)
- Sentiment breakdown per video (positive / neutral / negative)
- Videos with impressions but zero clicks (data quality check)
- Videos and their peak daily views date
- Creators who published more than 10 videos
- Videos with multiple high-spike days
- Videos with revenue but zero views (data mismatch)
- Creator-wise average CTR

---

### 🟠 Window Functions & Ranking (31–39)
Advanced analytics using SQL window functions.

- Rank videos by total views within each category
- Running total of views per video
- Monthly growth rate of views using `LAG`
- Top 3 videos per month
- Percentile of views per video using `NTILE`
- Day-over-day view percentage change using `LAG`
- Cumulative watch time per creator
- Rank creators by average watch duration
- Deduplicate daily stats using `ROW_NUMBER`

---

### 🔴 Advanced & Analytics (40–50)
Business-level KPIs, anomaly detection, and complex analytics.

- Engagement score: `(likes + comments + clicks) / impressions`
- Z-score anomaly detection on daily views
- Creator retention rate: % of videos still active after 90 days
- High drop-off video detection (avg watch duration vs. total length)
- Creator lifetime value: total revenue normalized by video count
- CTR by video length segment (Short / Medium / Long)
- Top comment contributors by author
- High-impression videos with zero revenue
- Monthly revenue pivot by category (Jan–Jun 2023)
- Multi-stage conversion funnel: impressions -> clicks -> views -> watch time
- Data inconsistency flag: daily views with no matching likes record

---

## Tech Stack

- **Database**: MySQL 8.0+
- **Language**: SQL (DDL + DML + Window Functions + CTEs)
- **Data Format**: CSV (imported via MySQL Workbench or `LOAD DATA INFILE`)
- **Tools**: MySQL Workbench / DBeaver / any MySQL-compatible client

---

## Project Structure

```
youtube-analytics-mysql/
│
├── README.md
├── YouTube_Analytics_MySQL_Project.sql        # All 50 queries
│
└── data/
    ├── creators_dataset.csv
    ├── videos_dataset.csv
    ├── daily_views_dataset.csv
    ├── likes_dislikes_Youtube_data_analytics_dataset.csv
    ├── comments_dataset_youtube_analytics_project.csv
    └── revenue_dataset_YouTube_Data_Analytics_Project.csv
```

---

## Getting Started

### 1. Create the database

```sql
CREATE DATABASE YouTube;
USE YouTube;
```

### 2. Import the CSV files

Import each `.csv` file into MySQL as a table. You can use MySQL Workbench's **Table Data Import Wizard** or use the following pattern:

```sql
LOAD DATA INFILE '/path/to/creators_dataset.csv'
INTO TABLE creators_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

Repeat for each dataset file.

### 3. Run the queries

Open `YouTube_Analytics_MySQL_Project.sql` in your MySQL client and execute queries individually or as a batch.

---

## Sample Queries

**Top 10 videos by total views:**
```sql
SELECT video_id, SUM(views) AS TotalViews
FROM daily_views_dataset
GROUP BY video_id
ORDER BY TotalViews DESC
LIMIT 10;
```

**Engagement score per video:**
```sql
SELECT video_id,
       (total_likes + total_comments + total_clicks) * 1.0 / total_impressions
       AS engagement_score
FROM agg
ORDER BY engagement_score DESC;
```

**Monthly view growth rate using LAG:**
```sql
SELECT video_id, mnth, views, Prev_Mnth_views,
       ((views - Prev_Mnth_views) / Prev_Mnth_views) * 100 AS growth_rate
FROM cte1;
```

---

## Key Insights Unlocked

- Which creators generate the highest revenue per video published
- Which videos have high impressions but fail to convert (low CTR)
- Anomaly days where view counts deviate significantly from the mean (Z-score)
- Content retention: how many videos remain active 90+ days after publish
- Engagement leaders — videos that maximize audience interaction relative to reach
- Content length sweet spot — whether short, medium, or long videos perform best by CTR
- Data quality gaps — revenue without views, likes without daily stats

---

## Author

Built as a MySQL portfolio project to demonstrate end-to-end SQL proficiency across data retrieval, transformation, and advanced analytics on a realistic multi-table schema.

---

🤝 Contributing

Contributions are welcome! If you'd like to improve this project, feel free to fork the repository and submit a pull request 🚀

---

> ⭐ If you found this project useful, consider starring the repository!
