# Contributing to Twift
Thanks for your interest in contributing to Twift! This library is still young, so may not cover all your needs or work the way you expected—whether you have ideas for improving it, or want to add new methods and types, contributions and discussion are actively welcomed!

Below are some things to bear in mind when contributing to the library.

## Documentation
Thorough documentation is an important part of making this library useful. All new methods and types should be documented with:

- A title or summary
- A detailed description (optional)
- Parameters (where applicable)
- Return types (where applicable)

Please refer to Apple’s developer documentation article detailing [how to write symbol documentation in source files](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files).

Where possible, documentation for object properties, methods, and method parameters should copy [Twitter’s API documentation](https://developer.twitter.com/en/docs/twitter-api).

## Testing (⚠️ Work In Progress)
Proper testing has not yet been developed for Twift; I’d advise testing your contributions locally by linking the library to a test app.

## Adding API Calls
Twift’s API methods follow a common implementation:

1. Accept parameters specific to the API endpoint
2. Call the internal `call()` method with the desired route, HTTP method, body data (where applicable), and query parameters
3. Throw any errors encountered
4. Return a decoded `TwitterAPI` response with data, includes, and/or metadata

The easiest way to figure out how to write a new method is to reference methods already in the library. Some examples:

1. A paginated request with data, includes, and metadata (`GET /2/tweets/:id/liked_by`): [`getLikingUsers(for tweetId)`](https://github.com/daneden/Twift/blob/cd6b878c3955e7c60daba4db208cc867e5a59895/Sources/Twift%2BLikes.swift#L48)
2. A data-only request (`POST /2/users/:user_id/likes`): [`likeTweet(_ tweetId)`](https://github.com/daneden/Twift/blob/cd6b878c3955e7c60daba4db208cc867e5a59895/Sources/Twift%2BLikes.swift#L11)

## Style Guide

### Naming
Symbols should follow Twitter’s API names as closely as possible, favouring `camelCase` instead of `snake_case` for member names.

Method names should follow a rule of `{action}{Object}`, for example `postTweet()` or `getLists()`. When in doubt about what the right `action` is, prefer to use the HTTP method for the API endpoint.

### File Organisation
The library is organised into two types of files:

1. Class extensions (`Twift+Example.swift`)
2. Type extensions (`Types+Example.swift`)

Create type extension files to globally define types for new objects (e.g. Tweets or Spaces). Create class extensions to extend the `Twift` class and implement methods related to specific objects.

### Immutability 
You should prefer `let` over `var` for struct properties unless the struct is intentionally mutable (for example, when the struct will be used to post data to the Twitter API).

### Concurrency
Always prefer writing methods as `async` where possible.

### Access Control
Always mark objects, methods, and members as `public` if they are intended to be used by library consumers. Prefer `fileprivate` access control for internal implementation details, or `internal` where implementation details are shared throughout the library.
