-- Spotify SQL Project
CREATE database spotify;
use spotify;

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- 1. Data Exploration
select *  from spotifyy;
SELECT artist FROM spotifyy;
SELECT COUNT(*) FROM spotifyy;
SELECT COUNT(DISTINCT artist) FROM spotifyy;
SELECT DISTINCT album FROM spotifyy;
DELETE FROM spotifyy
WHERE duration_min = 0;
SELECT * FROM spotifyy
WHERE duration_min = 0;
SELECT DISTINCT channel FROM spotifyy;

-- 2. Querying the Data
-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT DISTINCT track, stream
FROM spotifyy
WHERE stream >= 1000000000;

-- 2. List all albums along with their respective artists.
SELECT  DISTINCT artist, album
FROM spotifyy;

-- 3. Get the total number of comments for tracks where licensed = TRUE
SELECT SUM(comments) AS total_comments
FROM spotifyy
WHERE licensed = 'TRUE';

-- 4. Find all tracks that belong to the album type single
SELECT *
FROM spotifyy
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.
SELECT artist, COUNT(track) AS total_tracks
FROM spotifyy
GROUP BY artist
ORDER BY total_tracks DESC;

-- 6. Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) AS average_danceability
FROM spotifyy
GROUP BY album
ORDER BY average_danceability DESC;

-- 7. Find the top 5 tracks with the highest energy values.
SELECT track, max(energy) as highest_energy
FROM spotifyy
group by track
order by highest_energy desc
limit 5;

-- 8.  List all tracks along with their views and likes where official_video = TRUE.
SELECT track,views,likes
FROM spotifyy
WHERE official_video = 'TRUE';


-- 9. For each album, calculate the total views of all associated tracks.
SELECT track, album, SUM(views) AS total_views
FROM spotifyy
GROUP BY track,album
ORDER BY total_views DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM (
    SELECT track, 
		-- most played on
        COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotifyy
    GROUP BY track
     ) AS t1
WHERE  streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0;

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH RankedTracks AS (
    SELECT artist, track, SUM(views) AS total_view,
          DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS d_rnk
    FROM spotifyy
    GROUP BY artist,track
)
SELECT *
FROM RankedTracks
WHERE d_rnk <=32;

-- 12. Write a query to find tracks where the liveness score is above the average.
select track, artist, liveness
from spotify
where liveness > (select avg(liveness) from spotifyy);

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte as
	(select album, 
    max(energy) as highest_energy, 
    min(energy) as lowest_energy
	from spotifyy
	group by album)
select album, highest_energy - lowest_energy as energy_diff
from cte
order by energy_diff desc;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT track, energy, liveness, (energy / liveness) AS energy_liveness_ratio
FROM spotifyy
WHERE (energy / liveness) > 1.2
ORDER BY energy_liveness_ratio DESC;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    artist, 
    track, 
    views, 
    likes, 
    SUM(likes) OVER w AS cumulative_likes
FROM 
    spotifyy
WINDOW w AS (ORDER BY views DESC)
ORDER BY views;


-- Query Optimization
EXPLAIN ANALYZE 
SELECT artist, track, views
FROM spotifyy
WHERE artist = 'Gorillaz' AND most_playedon = 'Youtube'
ORDER BY stream DESC 
LIMIT 25;
