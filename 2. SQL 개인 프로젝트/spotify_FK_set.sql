SELECT *
FROM track;

ALTER TABLE track
ADD CONSTRAINT fk_track_album_id
FOREIGN KEY (album_id)
REFERENCES album(album_id);

SELECT *
FROM details;

ALTER TABLE details
ADD CONSTRAINT fk_details_track_id
FOREIGN KEY (track_id)
REFERENCES track(track_id);

SELECT *
FROM track_artist;

ALTER TABLE track_artist
ADD CONSTRAINT fk_track_artist_track_id
FOREIGN KEY (track_id)
REFERENCES track(track_id);

ALTER TABLE track_artist
ADD CONSTRAINT fk_track_artist_artist_id
FOREIGN KEY (artist_id)
REFERENCES artist(artist_id);

SELECT *
FROM album_artists;


select * from information_schema.table_constraints where table_name = 'album_artists';

--  에러
ALTER TABLE album_artists
ADD CONSTRAINT fk_album_artists_id
FOREIGN KEY (album_artists_id)
REFERENCES artist(artist_id);

ALTER TABLE album_artists
ADD CONSTRAINT fk_album_artists_album_id
FOREIGN KEY (album_id)
REFERENCES album(album_id);

SELECT *
FROM album_tracks;

ALTER TABLE album_tracks
ADD CONSTRAINT fk_album_tracks_album_id
FOREIGN KEY (album_id)
REFERENCES album(album_id);

--  에러
ALTER TABLE album_tracks
ADD CONSTRAINT fk_album_tracks_id
FOREIGN KEY (album_tracks_id)
REFERENCES tracks(tracks_id);

ALTER TABLE artist_genres
ADD CONSTRAINT fk_genres_artist_id
FOREIGN KEY (artist_id)
REFERENCES artist(artist_id);