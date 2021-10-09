# Appearance Planner 



This takes the information from my Google Docs spreadsheet and dumps it into a `.json` file that can be used to synchronize other services with my public appearances (virtual or otherwise). 

## Building 

Two files are required to build and run the application: `credentials.json` and `token.pickle`.

The first file, `credentials.json`, can be obtained by registering an application with Google Cloud. 
I have stored my particular version of this file in a Lastpass folder called `spring-tips-sheet`. You should do something (secure) with yours. Do _not_ check it into the code!  

If you run the program with only the first parameter present, it'll generate a `token.pickle` in the current directory. **But**, in order to do so, the program will open a browser and prompt you to approve the request. So, you'll need to do this on your local machine before running it in a headless environment.

The information in `token.pickle` is binary data, so I've run it through the following process:

```shell 
PICKLED_TOKEN=$( cat token.pickle | base64 ) 
```

In order to get this to work on Github Actions, I just copied the value to the clipboard and then pasted it into the `Secrets` section for my Github Actions as a new environment variable, `PICKLED_TOKEN`.  

```shell 
 cat token.pickle | base64 | pbcopy
```

I also created a new environment variable, `CREDENTIALS_JSON`, for the text data in the `credentials.json` file. 


   



