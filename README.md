# Appearance Planner 

This takes the information from my Google Docs spreadsheet and dumps it into a `.json` file that can be used to synchronize other services with my public appearances (virtual or otherwise). 


## Getting a New Token

The application uses a token from Google Cloud to talk to the spreadsheet. You need to go to https://console.cloud.google.com/apis/credentials?project=<YOUR_PROJECT> and create a new OAuth 2 Client ID, choose "Desktop" application. 

This program requires an Oauth client that is `Public`. You may specify that it's `Testing`, in which case it'll be limited to test users. Make sure to add yourself (in my case, `josh@joshlong.com`). 

Download the resulting `.json` file. 

Put the file somewhere safe and make sure that the `CREDENTIALS_JSON_FN` file points to it. If you're starting the 
program from scratch you'll need to authenticate and generate authenticated credentials, whose contents will live at the file path indicated by the environment variable `AUTHENTICATED_CREDENTIALS_JSON_FN`. Run the program locally, making sure that you've got no file stored at `AUTHENTICATED_CREDENTIALS_JSON_FN`. Delete the contents there. When you run the program locally, it'll open up a browser, prompting you to confirm access to Google. It'll then dump the authenticated credentials into the file indicated by `AUTHENTICATED_CREDENTIALS_JSON_FN`. Take the contents of both files - `CREDENTIALS_JSON_FN` and `AUTHENTICATED_CREDENTIALS_JSON_FN` - and store them in environment variables for the program in Github Actions, `CREDENTIALS_JSON` and `AUTHENTICATED_CREDENTIALS_JSON`  respectively, as Base64 encoded text.

## Running the program

Configure the OAuth consent 
screen for your project. Download the `.json` file and put it somewhere on the file system. Whern you run the 
program, make sure that `CREDENTIALS_JSON_FN` points to this file. Run it on your local machine and it'll redirect 
you to a Google login and ask you to confirm that you want to give the client these permissions. When it's done, 
it'll dump the authenticated credential in whatever path you put in `AUTHENTICATED_CREDENTIALS_JSON_FN`. Keep both `.
json` files and make them Github Secrets for the environment variables `CREDENTIALS_JSON` and 
`AUTHENTICATED_CREDENTIALS_JSON`.

## Dependencies 

The buildpack requires `requirements.txt`. It's easier to generate it in the build, locally, rather than trying to get it working 
in Github Actions. Use this command: `pip freeze > requirements.txt` and then don't forget to `git commit ` and `git push`. If you change `Pipfile`, make sure to 
rerun this command. You might also want to delete `Pipfile.lock` and then run `pipenv install`, too. 


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

