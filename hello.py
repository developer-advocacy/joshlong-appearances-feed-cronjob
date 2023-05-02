#!/usr/bin/env python3
import os, sys, time

if __name__ == '__main__':
    import requests
    url = 'https://jsonplaceholder.typicode.com/posts'
    response = requests.get(url)
    if response.status_code == 200:
        json_response = response.json()[0]
        print('result:', json_response)
