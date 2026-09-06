-- Codveda Business Analytics Internship
-- Project 1: Social Media Sentiment and Engagement Analysis
-- MySQL Business Analysis
-- Database: codveda_sentiment_analysis
-- Main table: sentiment_posts
-- Dataset size after import: 732 records

CREATE DATABASE IF NOT EXISTS codveda_sentiment_analysis;
USE codveda_sentiment_analysis;

DROP TABLE IF EXISTS platform_summary;
DROP TABLE IF EXISTS sentiment_posts;

CREATE TABLE sentiment_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    post_text TEXT,
    sentiment_raw VARCHAR(100),
    sentiment_group VARCHAR(20),
    post_timestamp VARCHAR(50),
    username VARCHAR(100),
    platform VARCHAR(20),
    hashtags VARCHAR(255),
    retweets INT,
    likes INT,
    country VARCHAR(100),
    post_year INT,
    post_month INT,
    post_day INT,
    post_hour INT
);

-- The cleaned CSV was imported through phpMyAdmin using this column order:
-- post_text, sentiment_raw, post_timestamp, username, platform, hashtags,
-- retweets, likes, country, post_year, post_month, post_day, post_hour,
-- sentiment_group. post_id was generated automatically by MySQL.

SELECT COUNT(*) AS total_posts FROM sentiment_posts;

SELECT
    SUM(CASE WHEN likes IS NULL THEN 1 ELSE 0 END) AS missing_likes,
    SUM(CASE WHEN retweets IS NULL THEN 1 ELSE 0 END) AS missing_retweets,
    SUM(CASE WHEN platform IS NULL THEN 1 ELSE 0 END) AS missing_platform
FROM sentiment_posts;

SELECT
    COUNT(DISTINCT country) AS distinct_countries,
    COUNT(DISTINCT platform) AS distinct_platforms
FROM sentiment_posts;

SELECT
    COUNT(*) AS total_posts,
    SUM(likes) AS total_likes,
    SUM(retweets) AS total_retweets,
    ROUND(AVG(likes), 2) AS average_likes,
    ROUND(AVG(retweets), 2) AS average_retweets
FROM sentiment_posts;

SELECT
    sentiment_group,
    COUNT(*) AS post_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sentiment_posts), 2) AS percentage_of_total,
    ROUND(AVG(likes), 2) AS average_likes,
    ROUND(AVG(retweets), 2) AS average_retweets
FROM sentiment_posts
GROUP BY sentiment_group
ORDER BY post_count DESC;

SELECT
    platform,
    COUNT(*) AS post_count,
    SUM(likes) AS total_likes,
    SUM(retweets) AS total_retweets,
    ROUND(AVG(likes), 2) AS average_likes,
    ROUND(AVG(retweets), 2) AS average_retweets
FROM sentiment_posts
GROUP BY platform
ORDER BY post_count DESC;

SELECT
    platform,
    SUM(CASE WHEN sentiment_group = 'Positive' THEN 1 ELSE 0 END) AS positive_posts,
    SUM(CASE WHEN sentiment_group = 'Negative' THEN 1 ELSE 0 END) AS negative_posts,
    SUM(CASE WHEN sentiment_group = 'Neutral' THEN 1 ELSE 0 END) AS neutral_posts,
    COUNT(*) AS total_posts
FROM sentiment_posts
GROUP BY platform
ORDER BY total_posts DESC;

SELECT
    country,
    COUNT(*) AS post_count,
    ROUND(AVG(likes), 2) AS average_likes,
    ROUND(AVG(retweets), 2) AS average_retweets
FROM sentiment_posts
GROUP BY country
ORDER BY post_count DESC
LIMIT 10;

SELECT
    post_year,
    COUNT(*) AS post_count,
    ROUND(AVG(likes), 2) AS average_likes,
    ROUND(AVG(retweets), 2) AS average_retweets
FROM sentiment_posts
GROUP BY post_year
ORDER BY post_year;

SELECT
    post_hour,
    COUNT(*) AS post_count
FROM sentiment_posts
GROUP BY post_hour
ORDER BY post_count DESC
LIMIT 5;

SELECT platform, country, sentiment_group, likes, retweets
FROM sentiment_posts
ORDER BY likes DESC, retweets DESC
LIMIT 5;

SELECT COUNT(*) AS high_engagement_negative_posts
FROM sentiment_posts
WHERE sentiment_group = 'Negative'
  AND likes > (SELECT AVG(likes) FROM sentiment_posts);

SELECT ROUND(SUM(likes) / NULLIF(SUM(retweets), 0), 3) AS likes_to_retweets_ratio
FROM sentiment_posts;

CREATE TABLE platform_summary AS
SELECT
    platform,
    COUNT(*) AS platform_posts,
    ROUND(AVG(likes), 2) AS platform_average_likes,
    ROUND(AVG(retweets), 2) AS platform_average_retweets
FROM sentiment_posts
GROUP BY platform;

ALTER TABLE platform_summary ADD PRIMARY KEY (platform);

SELECT
    s.post_id,
    s.platform,
    s.sentiment_group,
    s.likes,
    s.retweets,
    p.platform_posts,
    p.platform_average_likes,
    p.platform_average_retweets
FROM sentiment_posts AS s
INNER JOIN platform_summary AS p
    ON s.platform = p.platform
ORDER BY s.likes DESC
LIMIT 20;

SELECT
    s.platform,
    COUNT(*) AS posts_above_platform_average
FROM sentiment_posts AS s
INNER JOIN platform_summary AS p
    ON s.platform = p.platform
WHERE s.likes > p.platform_average_likes
GROUP BY s.platform
ORDER BY posts_above_platform_average DESC;

CREATE INDEX idx_platform ON sentiment_posts(platform);
CREATE INDEX idx_sentiment_group ON sentiment_posts(sentiment_group);
CREATE INDEX idx_country ON sentiment_posts(country);
CREATE INDEX idx_year ON sentiment_posts(post_year);
CREATE INDEX idx_hour ON sentiment_posts(post_hour);

SHOW INDEX FROM sentiment_posts;

EXPLAIN
SELECT platform, COUNT(*) AS post_count
FROM sentiment_posts
WHERE sentiment_group = 'Positive'
GROUP BY platform;

-- End of script
