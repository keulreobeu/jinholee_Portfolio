import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pprint



# key_1
# client_credentials_manager = SpotifyClientCredentials(client_id='e48676801c514fd0a6202eb890eaa0f1', client_secret='발급받은 키')

# key_2
# client_credentials_manager = SpotifyClientCredentials(client_id='5022af45601e4149a0881fbbe27eef62', client_secret='발급받은 키')

# key_3
client_credentials_manager = SpotifyClientCredentials(client_id='f588ee129cec4da4a194ece6210ffab6', client_secret='발급받은 키')

sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)



def album_id_search(albums_id):
    """엘범의 아이디를 최대 20개씩 spotipy를 통해 불러와, 엘범 이름과 그 엘범의 수록된 track의 id를 가져온다.

    Args:
        albums_id (STR in list): 엘범의 id를 리스트에

    Returns:
        딕셔너리: {album_name : tracks_id}
    """
    batch_size = 20
    for i in range(0, len(albums_id), batch_size):        
        batch_album_ids = albums_id[i:i+batch_size]
        albums = sp.albums(batch_album_ids)['albums']
        
        for album in albums:
            album_tracks_id = []
            resert = {}
            
            album_name = (album['name'])
            total = album['total_tracks']
            for j in range(total):
                album_tracks_id.append(album['tracks']['items'][j]['id'])
            resert[album_name] =  album_tracks_id
    return resert



def playlist_id(id):
    """
    단일 playlist의 id로 검색하여 playlist에 들어있는 track의 id를 반환해줌
    playlist_id 목록을 넣으면 안됨

    Args:
        id (STR): playlist의 id를 입력해야함.

    Returns:
        list: 검색된 playlist의 track_id가 담겨있는 list
    """
    
    id_list = []
    offset = 0
    limit = 100
    while True:
        playlist = sp.playlist_tracks(id, limit=limit, offset=offset)
        tracks = playlist['items']
        for item in tracks:
            track_id = item['track']['id']
            id_list.append(track_id)
        
        offset += limit
        if len(tracks) < limit:
            break
    
    return id_list



def track_id_search(ids, DF=True, give_artist_id=False):
    """track의 id로 트렉의 정보를 받아옵니다.
    설정에 따라 DataFrame으로 받거나 dict로 받을 수 있습니다.
    설정에 따라 artist_id의 리스트를 받을 수 있습니다.

    Args:
        ids (list): 트랙의 id를 리스트형태로 입력해야합니다. 각 ID는 STR타입으로 입력해야합니다.
        DF (bool, optional): 데이터를 DataFrame으로 받을지 Dict로 받을지 선택할 수 있습니다. Defaults to True.
        give_artist_id (bool, optional): artist_id_list를 받을 수 있습니다. 중복은 없습니다. Defaults to False.

    Returns:
        Union[pandas.DataFrame, dict]: track의 정보를 DataFrame 객체 또는 사전(dict)을 반환할 수 있습니다.
        Optional[list]: artist_id를 리스트로 된 결과값을 반환할 수도 않을 수도 있습니다.
    """
    
    track_data = {'track_id': [],
                'track_name': [],
                'track_popularity': [],
                'album_id': []}
    
    if give_artist_id == True:
        artist_id_list = []
    
    batch_size = 20
    
    for i in range(0, len(ids), batch_size):
        batch_album_ids = ids[i:i+batch_size]
        tracks = sp.tracks(batch_album_ids)['tracks']
        for track in tracks:
            track_data['track_name'].append(track['name'])
            track_data['track_id'].append(track['id'])
            track_data['track_popularity'].append(track['popularity'])
            track_data['album_id'].append(track['album']['id'])
            if give_artist_id == True:
                for j in range(len(track['artists'])):
                    artist_id_list.append(track['artists'][j]['id'])

    if DF == True:
        track_data = pd.DataFrame(track_data)

    if give_artist_id == True:
        return track_data, list(set(artist_id_list))
    else:
        return track_data
    
    
    
def details_to_df(ids):
    """track의 id로 track features를 받아옴 최대 20개씩 받아옴.

    Args:
        ids (ist): track의 id를 리스트로 저장해둔 변수

    Returns:
        DataFrame: track features를 DF형태로 반환함.
        columns = ['danceability', 'energy', 'key', 'loudness', 'mode', 'speechiness', 'acousticness', 'instrumentalness', 'liveness', 'valence', 'tempo', 'type', 'id', 'url', 'track_href', 'analysis_url', 'duration_ms', 'time_signature']
    """
    track_details_df = pd.DataFrame(columns = ['danceability', 'energy', 'key', 'loudness', 'mode', 'speechiness', 'acousticness', 'instrumentalness', 'liveness', 'valence', 'tempo', 'type', 'id', 'url', 'track_href', 'analysis_url', 'duration_ms', 'time_signature'])
    track_features=[]
    batch_size = 20
    for i in range(0, len(ids), batch_size):
        batch_track_ids = ids[i:i + batch_size]
        batch_af = sp.audio_features(batch_track_ids)
        track_features.append(batch_af)
            
    for item in track_features:
        for feat in item:
            track_details_df = track_details_df.append(feat, ignore_index=True)
            
            
    track_details_df = track_details_df.drop(['key', 'mode','type','url','track_href', 'analysis_url','time_signature', 'uri'], axis=1)

    new_order = ['id', 'danceability', 'energy','loudness','speechiness', 'acousticness', 'instrumentalness', 'liveness', 'valence', 'tempo', 'duration_ms']
    track_details_df = track_details_df.reindex(columns=new_order)
    track_details_df = track_details_df.rename(columns={'id': 'track_id'})
    return track_details_df



def search_track_id_year(number, year=2021):
    """track_id를 연도기준으로 가져옵니다.

    Args:
        number (int): 가져올 트랙 개수입니다.
        year (int, optional): 연도 설정입니다. Defaults to 2021.

    Returns:
        list: track_id를 리스트로 반환합니다.
    """
    track_id =[]
    for i in range(0,number,50):
        track_results = sp.search(q=f'year:{year}', type='track', limit=50, offset=i)
        for i, t in enumerate(track_results['tracks']['items']):
            track_id.append(t['id'])
    return track_id