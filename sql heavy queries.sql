SELECT channelId,
channelTitle
,max(channelSubscriberCount) channelSubscriberCount
,max(channelVideoCount) channelvideocount
,round(max(channelViewCount)/count(videoId)) avgViewPerVideo
FROM `you-tube-api-486713.youtube_list.youtube_fact` 
group by 1,2;

--for avg videoduration:--
select channelId,
channelTitle,
ROUND(avg(videoDuration),1) avgDuration
 from `you-tube-api-486713.youtube_list.youtube_fact` 
group by 1,2;

-- focus on one channel 'krish naik'
with base as(
select videoDurationBucket 
,count(*) nVideos
from `you-tube-api-486713.youtube_list.youtube_fact` where channelID='UCNU_lfiiWBdtULKOw6X0Dig'
group by 1)
select *
,round(nVideos*100/(select sum(nVideos) from base),1) pershare
from base;

--best performing month--
with base as(
select date(date_trunc(videoPublishedAt,month )) as publishedmonth
,count(*) nVideos
,sum(videoViews) total_views
from `you-tube-api-486713.youtube_list.youtube_fact` where channelID='UCNU_lfiiWBdtULKOw6X0Dig'
group by 1)

select *
,round(nVideos*100/(select sum(nVideos) from base),1) pershare
,dense_rank() over(order by nVideos) videoRank
,dense_rank() over(order by total_views) viewRank
,total_views/nVideos as pervideoview
from base where nVideos>5
order by pervideoview desc ,viewRank,publishedmonth desc;

--Top viewed video--
select * from `you-tube-api-486713.youtube_list.youtube_fact` 
where channelID='UCNU_lfiiWBdtULKOw6X0Dig'
order by videoViews desc limit 10;

--best outlier video--
select videoId
, videoTitle
,videoViews
,videoPublishedAt
,videoViews/date_diff(current_date, date(videoPublishedAt), day) videoviewsperday
from `you-tube-api-486713.youtube_list.youtube_fact` 
where channelID='UCNU_lfiiWBdtULKOw6X0Dig'
order by videoViews desc








