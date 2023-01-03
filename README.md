# joshlong.com/feed.html feed generator 

This captures information related to my public appearances and writes them out to a `.json` file so that they can be integrated into feeds, like on [joshlong.com/feed.html](https://joshlong.com/feed.html)

This script requires certain environment variables specific to this particular application. I've put those in a Lastpass folder called `developer-advocacy` under the name `appearances-processor`. 

This requires two variables - `AUTHENTICATED_CREDENTIALS_JSON`, AND `CREDENTIALS_JSON` to contain the values of `authenticated-credentials.json` and `credentials.json` under the `developer-advocacy` folder in LastPass. The contents of these variables should be the `base64` encoded values of those files. 




## Appearance Planner 

This takes the information from my Google Docs spreadsheet and dumps it into a `.json` file that can be used to synchronize other services with my public appearances (virtual or otherwise). 

## Getting a New Token

The application uses a token from Google Cloud to talk to the spreadsheet. You need to go to https://console.cloud.google.com/apis/credentials?project=<YOUR_PROJECT> and create a new OAuth 2 Client ID, choose "Desktop" application, then download the resulting .json file



## Building 

Two files are required to build and run the application: `credentials.json` and `token.pickle`.

The first file, `credentials.json`, can be obtained by registering an application with Google Cloud. 
I have stored my particular version of this file in a Lastpass folder called `spring-tips-sheet`. You should do something (secure) with yours. Do _not_ check it into the code!  

If you run the program with only the first parameter present, it'll generate a `token.pickle` in the current directory. **But**, in order to do so, the program will open a browser and prompt you to approve the request. So, you'll need to do this on your local machine before running it in a headless environment.

The information in `token.pickle` is binary data, so I've run it through the following process:

```shell 
PICKLED_TOKEN=$( cat token.pickle | base64 ) 
```

In order to get this to work on GitHub Actions, I just copied the value to the clipboard and then pasted it into the `Secrets` section for my GitHub Actions as a new environment variable, `PICKLED_TOKEN`.  

```shell 
 cat token.pickle | base64 | pbcopy
```

I also created a new environment variable, `CREDENTIALS_JSON`, for the text data in the `credentials.json` file. 

