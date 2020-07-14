import json
import os
import sys

from sheets import *

import typing


class Appearance(object):

    def __str__(self) -> str:
        lines = []
        for k, v in self.__dict__.items():
            lines.append('%s: %s' % (k, v))
        return str(', '.join(lines))

    def __init__(self,
                 appearance: str = None,
                 location: str = None,
                 start_date: str = None,
                 end_date: str = None,
                 time: str = None,
                 location_address: str = None,
                 confirmed: bool = None,
                 contact: str = None,
                 notes: str = None,
                 eyeballs: int = 0,
                 is_public: bool = False,
                 marketing_blurb: str = None) -> None:
        self.appearance = appearance
        self.location = location
        self.start_date = start_date
        self.end_date = end_date
        self.time = time
        self.location_address = location_address
        self.confirmed = confirmed
        self.contact = contact
        self.notes = notes
        self.eyeballs = eyeballs
        self.is_public = is_public
        self.marketing_blurb = marketing_blurb


def read_appearances_from_google_sheet(client_config, tab: str, tab_range: str, spreadsheet_id: str):
    sheet = GSheet(client_config, spreadsheet_id)
    values = sheet.read_values('%s!%s' % (tab, tab_range))

    appearances = []

    def default_converter(col: str) -> str:
        return col

    def convert_bool(col: str) -> bool:
        return not (col is None or col.strip() == '' or col.strip().lower() == 'false' or col.strip().lower() == 'no')

    custom_parsers = {'is_public': convert_bool, 'confirmed': convert_bool}
    cols = [a.strip() for a in
            'appearance, location, start_date, end_date, time, location_address,'
            'confirmed, contact, notes, eyeballs, is_public, marketing_blurb'.split(',')]
    for row in values[1:]:

        # this is a little hacky. we know that there can be any of `cols` columns.
        # but the results that we get back are ragged if the righter-most columns are empty
        # so we go L-to-R, incrementing an offset one by one, and noting values
        # for as far to the right as we can in a dictionary

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


def main(args):
    

    def production_values():
        return [os.environ[a] for a in
                ['GS_TAB_NAME', 'GS_TAB_RANGE', 'GS_KEY', 'GOOGLE_CREDENTIALS_JSON', 'JSON_FN']]

    tab_name, sheet_range, sheet_key, credentials_file, output_file_name = production_values()
    
    assert os.path.exists(credentials_file), 'the file %s does not exist' % credentials_file
    with open(credentials_file, 'r') as json_file:
        client_config = json.load(json_file)
    
    appearances = read_appearances_from_google_sheet(
        client_config, tab_name, sheet_range, sheet_key)

    def create_public_view(entry: typing.Dict) -> typing.Dict:
        public_keys = ['appearance', 'location', 'start_date', 'end_date', 'time', 'location_address', 'marketing_blurb']
        result = {}
        for pk in public_keys:
            if pk in entry:
                result[pk] = entry[pk]
        return result

    public_appearances = [create_public_view(a.__dict__) for a in appearances if a.is_public is True]

    with open(output_file_name, 'w') as fp:
        fp.write(json.dumps(public_appearances))


if __name__ == '__main__':
    main(sys.argv)
