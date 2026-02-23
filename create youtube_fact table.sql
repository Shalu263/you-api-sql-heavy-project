--1)To check duplicates in table 'all youtube videos'
SELECT videoId
FROM `you-tube-api-486713.youtube_list.all youtube videos`
group by 1 having count(*)>1;

--To check videoId is primary key...should not carry null(same table)
SELECT videoId
FROM `you-tube-api-486713.youtube_list.all youtube videos`
where videoId is null;

--for table all youtube videos same questions
--2)To check duplicates:
SELECT videoId
FROM `you-tube-api-486713.youtube_list.all youtube videos`
group by 1 having count(*)>1;

--to check null values etc
SELECT videoId
FROM `you-tube-api-486713.youtube_list.all youtube videos`
where videoId is null;

--NOW BASE TABLE AND ALL THE ADVANCE QUERYING WE'LL DO--
create or replace table youtube_list.youtube_fact as
WITH base AS (
  SELECT * 
  FROM `you-tube-api-486713.youtube_list.youtube channel list`
)

,channel_metadata AS (
  SELECT *,
         ROW_NUMBER() OVER (
             PARTITION BY channelId 
             ORDER BY channelViewCount DESC
         ) dataRank
  FROM `you-tube-api-486713.youtube_list.you tube channel data`
  QUALIFY dataRank = 1
)

,youtube_videos AS (
  SELECT * 
  FROM `you-tube-api-486713.youtube_list.Youtube_channel videos`
)

,youtube_metadata AS (
  SELECT * 
  FROM `you-tube-api-486713.youtube_list.all youtube videos`
)

,youtube_stats AS (
  SELECT * 
  FROM `you-tube-api-486713.youtube_list.youtube_stats`
)

,final AS (
  SELECT 
    base.channelId,
    channel_metadata.channelTitle,
    
    youtube_videos.videoId,
    youtube_videos.title AS videoTitle,
    youtube_videos.publishedAt AS videoPublishedAt,
    
    CAST(youtube_metadata.videoDuration AS FLOAT64) AS videoDuration,
    CAST(youtube_metadata.videoDuration AS FLOAT64)/60 AS videoDurationMin,
    CAST(youtube_stats.videoViews AS INT64) AS videoViews,
    CAST(youtube_stats.videoLikes AS INT64) AS videoLikes,
    CAST(youtube_stats.videoComments AS INT64) AS videoComments,
    
    youtube_metadata.videoQuality,
    youtube_videos.description AS videoDescription,
    
    channel_metadata.channelDescription,
    CAST(channel_metadata.channelSubscriberCount AS INT64) AS channelSubscriberCount,
    CAST(channel_metadata.channelVideoCount AS INT64) AS channelVideoCount,
    channel_metadata.channelPublishedAt,
    base.url

  FROM base

  LEFT JOIN channel_metadata 
      ON channel_metadata.channelId = base.channelId
  LEFT JOIN youtube_videos 
      ON youtube_videos.channelId = base.channelId
  LEFT JOIN youtube_metadata 
      ON youtube_metadata.videoId = youtube_videos.videoId
  left join youtube_stats 
      on youtube_stats.videoId = youtube_videos.videoId)

 SELECT *,
   case WHEN videoDuration IS NULL THEN '0. NA'
    WHEN videoDuration < 60 THEN '1. Short (<1 min)'
    WHEN videoDuration < 300 THEN '2. Medium (1–5 min)'
    WHEN videoDuration < 900 THEN '3. Long (5–15 min)'
    WHEN videoDuration < 1800 THEN '4. Extended (15–30 min)'
    ELSE '5. Very Long (30+ min)'
END AS videoDurationBucket
from final











