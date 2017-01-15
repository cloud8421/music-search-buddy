# Music Search

A simple app to search for music on multiple sources (e.g. Spotify, Apple Music, etc).

Available at <http://ms.fullyforged.com>

# Development

- `make install`
- `make`

# Deployment

The app is deployed on surge.sh (deployment happens automatically for the master branch via GitLab CI).

# The music search api

The application relies on a small api which proxies all calls to the relevant providers (iTunes, Spotify). Source code for the apy proxy is available [here](https://github.com/cloud8421/music-search-buddy-api).
