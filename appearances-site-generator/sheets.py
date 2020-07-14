import os.path
import os.path
import pickle

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build


class GSheet(object):
    USER_ENTERED = 'USER_ENTERED'
    INPUT_VALUE_OPTION_UNSPECIFIED = 'INPUT_VALUE_OPTION_UNSPECIFIED'
    RAW = 'RAW'

    @staticmethod
    def _obtain_token(credentials_config_str: str) -> Credentials:
        # if modifying these scopes, delete the file token.pickle.
        scopes = ['https://www.googleapis.com/auth/drive']
        credentials: Credentials = None
        if os.path.exists('token.pickle'):
            with open('token.pickle', 'rb') as token:
                credentials = pickle.load(token)
        if not credentials or not credentials.valid:
            if credentials and credentials.expired and credentials.refresh_token:
                credentials.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_config(credentials_config_str, scopes)
                credentials = flow.run_local_server(port=0)
                with open('token.pickle', 'wb') as token:
                    pickle.dump(credentials, token)
        return credentials

    def write_values(self, spreadsheet_range: str, input_option: str, values: list):
        body = {'values': values}
        result = self.service.spreadsheets().values().update(
            spreadsheetId=self.id,
            range=spreadsheet_range,
            valueInputOption=input_option,
            body=body) \
            .execute()
        print('{0} cells updated.'.format(result.get('updatedCells')))
        return result

    def read_values(self, spreadsheet_range: str) -> list:
        sheet = self.service.spreadsheets()
        result = sheet.values().get(
            spreadsheetId=self.id, range=spreadsheet_range).execute()
        return result.get('values', [])

    def __init__(self, credentials: str, spreadsheet_id: str):
        token = self._obtain_token(credentials)
        self.service = build('sheets', 'v4', credentials=token)
        self.id = spreadsheet_id
