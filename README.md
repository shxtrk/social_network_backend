# Social Network Backend

This is an backend written in Swift for a social network application where user can create posts, likes, subscribe to other users and receive a subscription feed. Current implementation also supports authorization. It uses Vapor framework and SQLite database.

## API Reference

### Auth

```
  POST /auth
```

* Route uses **Basic Auth**
* All subsequent routes use Bearer Auth unless otherwise specified

### Users

#### Create User

```
  POST /users
```

| Parameter | Type     |
| :-------- | :------- |
| `userName`    | `file` |
| `email`    | `string` |
| `password`    | `string` |
| `confirmPassword`    | `string` |

* No auth required

#### Get User

```
  GET /users/:userId
```

#### Delete User

```
  DELETE /users/:userId
```

#### Update User

```
  PUT /users/:userId
```

#### Get All Users

```
  GET /users
```

#### Get User Likes

```
  GET /users/:userId/likes
```

### Followers

#### Follow User

```
  POST /users/:userId/followers/:followingId
```

#### Unfollow User

```
  DELETE /users/:userId/followers/:followingId
```

### Posts

#### Create Post

```
  POST /users/:userId/posts
```

| Parameter | Type     |
| :-------- | :------- |
| `text`    | `string` |

#### Get All Posts

```
  GET /users/:userId/posts
```

#### Upload Image For Post

```
  POST /users/:userId/posts/:postId/upload_image
```

| Parameter | Type     |
| :-------- | :------- |
| `data`    | `file` |
| `filename`    | `string` |
| `extension`    | `string` |

* **filename** parameter shoul correspond to **postId**

#### Delete Post

```
  DELETE /users/:userId/posts/:postId
```

#### Get Post

```
  GET /users/:userId/posts/:postId
```

### Likes

#### Like Post

```
  POST /posts/:postId/likes
```

#### Unlike Post

```
  DELETE /posts/:postId/likes
```

### Feed

#### Get user Feed

```
  GET /users/:userId/feed
```
## License

[MIT](https://choosealicense.com/licenses/mit/)

MIT License

Copyright (c) 2023 Serhii Striuk

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Authors

- [@shxtrk](https://github.com/shxtrk)
