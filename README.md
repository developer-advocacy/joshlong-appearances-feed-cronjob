# joshlong.com/feed.html feed generator 

This captures information related to my public appearances and writes them out to a `.json` file so that they can be integrated into feeds, like on [joshlong.com/feed.html](https://joshlong.com/feed.html)

This script requires certain environment variables specific to this particular application. I've put those in a Lastpass folder called `joshlong.com` under the name `appearances-processor`. 

This requires two variables - `AUTHENTICATED_CREDENTIALS_JSON`, AND `CREDENTIALS_JSON` - to contain the values found in the Lastpass entries for `authenticated-credentials.json` and `credentials.json` in the `spring-tips-sheet` group. The contents of these variables should be the base64 encoded values of those files. 
