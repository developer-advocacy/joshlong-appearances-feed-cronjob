import json
import os
import typing

import auth
import google.sheets
from google import sheets


class Appearance(object):

    def __str__(self) -> str:
        lines = []
        for k, v in self.__dict__.items():
            lines.append('%s: %s' % (k, v))
        return str(', '.join(lines))

    def __init__(self,
                 notes: str = None,
                 type: str = None,
                 approved: bool = False,
                 event: str = None,
                 location: str = None,
                 start_date: str = None,
                 end_date: str = None,
                 time: str = None,
                 location_address: str = None,
                 confirmed: bool = None,
                 contact: str = None,
                 eyeballs: int = 0,
                 is_public: bool = False,
                 marketing_blurb: str = None) -> None:
        self.event = event
        self.location = location
        self.start_date = start_date
        self.end_date = end_date
        self.time = time
        self.approved = approved
        self.location_address = location_address
        self.confirmed = confirmed
        self.contact = contact
        self.notes = notes
        self.eyeballs = eyeballs
        self.is_public = is_public
        self.marketing_blurb = marketing_blurb
        self.type = type


def read_appearances_from_google_sheet(sheet: google.sheets.GoogleSheet, tab: str, tab_range: str):
    values = sheet.read_values('%s!%s' % (tab, tab_range))
    appearances = []

    def default_converter(col: str) -> str:
        return col

    def bool_converter(col: str) -> bool:
        valid = [a.strip() for a in ['y', 't', '1']]
        return col is not None and col.lower().strip() in valid

    custom_parsers = {'is_public': bool_converter, 'confirmed': bool_converter}
    cols = [a.strip() for a in
            ['event', 'type', 'start_date', 'end_date', 'notes', 'time', 'location', 'opportunity_number',
             'subject_content', 'approved', 'is_public', 'marketing_blurb', 'speaking_engagement', 'location_address',
             'contact', 'eyeballs']]
    for row in values[1:]:
        ctr = 0
        d = {}
        len_of_row = len(row)
        for c in cols:
            if len_of_row > ctr:
                d[c] = row[ctr]
            ctr += 1
        appearance = Appearance()
        for k, v in d.items():
            parser = default_converter
            if k in custom_parsers:
                parser = custom_parsers[k]
            setattr(appearance, k, parser(v))
        appearances.append(appearance)
    return appearances


def main():

    for k in os.environ.keys():
        print(k, '=', os.environ.get(k))

    scopes: list = ['https://www.googleapis.com/auth/drive', 'https://www.googleapis.com/auth/calendar']
    output_json_fn: str = os.path.expanduser(os.environ['OUTPUT_JSON_FN'])
    token_json_fn: str = os.path.expanduser(os.environ['CREDENTIALS_JSON_FN'])
    authenticated_token_json_fn: str = os.path.expanduser(os.environ['AUTHENTICATED_CREDENTIALS_JSON_FN'])
    credentials = auth.authenticate(token_json_fn, authenticated_token_json_fn, scopes)
    assert credentials is not None, 'the credentials must be valid!'
    sheet_id = os.environ['SHEET_ID']
    my_sheet: sheets.GoogleSheet = sheets.GoogleSheet(credentials, sheet_id)
    appearances = read_appearances_from_google_sheet(my_sheet, 'Josh', 'A:Z')

    def create_public_view(entry: typing.Dict) -> typing.Dict:
        print(entry)
        public_keys = ['event', 'start_date', 'end_date', 'time', 'marketing_blurb']
        result = {}
        for pk in public_keys:
            if pk in entry:
                result[pk] = entry[pk]
        return result

    public_appearances = [create_public_view(a.__dict__) for a in appearances if a.is_public is True]
    print(json.dumps(public_appearances))
    with open(output_json_fn, 'w') as fp:
        fp.write(json.dumps(public_appearances))
        print('wrote the feed to ', output_json_fn)


if __name__ == '__main__':
    main()
