#!/usr/bin/env python3
import requests

if __name__ == '__main__':
    url = 'https://jsonplaceholder.typicode.com/posts'
    response = requests.get(url)
    if response.status_code == 200:
        json_response = response.json()[0]
        print(json_response)
    else:
        print(f'Request failed with status code {response.status_code}')
