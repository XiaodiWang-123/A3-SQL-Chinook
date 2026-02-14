-- A3 SQL Assignment (Chinook / sqlite sample database)
-- Query 1 - Query 8

PRAGMA foreign_keys = ON;

-- =========================
-- Query 1: Create MusicVideo table (Track subtype)
-- One track can have 0 or 1 video; a video must belong to a track.
-- =========================
DROP TABLE IF EXISTS MusicVideo;

CREATE TABLE MusicVideo (
  TrackId       INTEGER NOT NULL,
  VideoDirector TEXT    NOT NULL,
  PRIMARY KEY (TrackId),
  FOREIGN KEY (TrackId) REFERENCES tracks(TrackId)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- =========================
-- Query 2: Insert at least 10 videos (respect rules)
-- =========================
INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 1' FROM tracks WHERE TrackId = 1;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 2' FROM tracks WHERE TrackId = 2;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 3' FROM tracks WHERE TrackId = 3;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 4' FROM tracks WHERE TrackId = 4;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 5' FROM tracks WHERE TrackId = 5;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 6' FROM tracks WHERE TrackId = 6;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 7' FROM tracks WHERE TrackId = 7;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 8' FROM tracks WHERE TrackId = 8;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 9' FROM tracks WHERE TrackId = 9;

INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'Director 10' FROM tracks WHERE TrackId = 10;

-- =========================
-- Query 3: Insert/Update video for track "Voodoo" without knowing TrackId
-- Uses subquery to find TrackId from name.
-- If the track already has a video, update director (keeps 0/1 rule).
-- =========================
INSERT INTO MusicVideo (TrackId, VideoDirector)
SELECT TrackId, 'New Director for Voodoo'
FROM tracks
WHERE Name = 'Voodoo'
LIMIT 1
ON CONFLICT(TrackId) DO UPDATE SET
  VideoDirector = excluded.VideoDirector;

-- =========================
-- Query 4: List all tracks with accented vowels (á,é,í,ó,ú) in the name
-- =========================
SELECT TrackId, Name
FROM tracks
WHERE Name GLOB '*[ÁáÉéÍíÓóÚú]*'
ORDER BY Name;

-- =========================
-- Query 5: Creative JOIN query (>= 2 tables)
-- List all tracks that have a music video, with album/artist/genre/director.
-- =========================
SELECT
    t.Name AS TrackName,
    al.Title AS AlbumTitle,
    ar.Name AS ArtistName,
    g.Name AS Genre,
    mv.VideoDirector
FROM MusicVideo mv
JOIN tracks t ON mv.TrackId = t.TrackId
LEFT JOIN albums al ON t.AlbumId = al.AlbumId
LEFT JOIN artists ar ON al.ArtistId = ar.ArtistId
LEFT JOIN genres g ON t.GenreId = g.GenreId
ORDER BY ArtistName, AlbumTitle, TrackName;

-- =========================
-- Query 6: Creative GROUP BY query (>= 2 tables)
-- Count music videos per genre.
-- =========================
SELECT
    g.Name AS Genre,
    COUNT(*) AS VideoCount
FROM MusicVideo mv
JOIN tracks t ON mv.TrackId = t.TrackId
LEFT JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY VideoCount DESC, Genre;

-- =========================
-- Query 7 (Bonus): Customers who listen to longer-than-average tracks
-- Excluding tracks longer than 15 minutes (900000 ms)
-- "Listen" inferred from purchases (invoice_items).
-- =========================
WITH AvgLen AS (
  SELECT AVG(Milliseconds) AS avg_ms
  FROM tracks
  WHERE Milliseconds <= 900000
),
LongTracks AS (
  SELECT TrackId
  FROM tracks, AvgLen
  WHERE Milliseconds > avg_ms
    AND Milliseconds <= 900000
)
SELECT DISTINCT
  c.CustomerId,
  c.FirstName,
  c.LastName,
  c.Email
FROM customers c
JOIN invoices i        ON i.CustomerId = c.CustomerId
JOIN invoice_items il  ON il.InvoiceId = i.InvoiceId
JOIN LongTracks lt     ON lt.TrackId = il.TrackId
ORDER BY c.LastName, c.FirstName;

-- =========================
-- Query 8 (Bonus): Tracks not in one of the Top 5 genres by average duration
-- =========================
WITH GenreAvg AS (
  SELECT
    GenreId,
    AVG(Milliseconds) AS avg_ms
  FROM tracks
  WHERE GenreId IS NOT NULL
  GROUP BY GenreId
),
Top5Genres AS (
  SELECT GenreId
  FROM GenreAvg
  ORDER BY avg_ms DESC
  LIMIT 5
)
SELECT
  t.TrackId,
  t.Name,
  g.Name AS Genre,
  t.Milliseconds
FROM tracks t
LEFT JOIN genres g ON g.GenreId = t.GenreId
WHERE t.GenreId IS NULL
   OR t.GenreId NOT IN (SELECT GenreId FROM Top5Genres)
ORDER BY Genre, t.Name;
