# ReadyBase

ReadyBase is a generic backend service for web applications that provides user registration/authentication and relational data persistence through a REST API, built with Ruby on Rails and Postgresql.

The application stands on its own as a complete backend service, and you can optionally extend the code with custom functionality just as you would with any Ruby on Rails application.

## The Data Model and API

There are two main data types: users and objects. Users and objects both have the following attributes:

- `id`: read-only string, prefixed with `u_` for users and `o_` for objects.
- `data`: can be any valid JSON document.
- `belongs_to`: a JSON object that defines relationships with other objects and/or users.

`belongs_to` is expected to be a flat JSON object, where the keys are the names of the relationships and the values are `id`s of the related objects. For example, an object of type `post` might have a `belongs_to` value that looks something like

```js
{
  "author": "u_123",
  "blog": "o_456",
  "tags": ["o_789","o_321"]
}
```

Then, this `post` would be included in the collection returned in a GET request to the following endpoints.

```
/api/v1/users/u_123/posts
/api/v1/blogs/o_456/posts
/api/v1/tags/o_789/posts
/api/v1/tags/o_321/posts
```

Note that the names of the relationships do not need to match the `type`s of objects.

### Users

In addition to `id`, `data`, and `belongs_to`, users have the following attributes:

- `email`
- `username`
- `password`
- `roles`

Users can be created, read, updated, and deleted via the endpoints

```
/api/v1/users
/api/v1/users/<user_id>
```

A user session is established by POSTing credentials (username/email and password, or a cookie with auth token) to the endpoint

```
/api/v1/sessions
```

Using the JavaScript client (path: `public/readybase.js`), your browser code might look something like

```js
var emailInput = document.getElementById('email-input');
var passwordInput = document.getElementById('password-input');
// Registration
readybase.signUp(emailInput.value, passwordInput.value).then(function (userRecord) {
  var currentUserID = userRecord.id;
});

// Authentication with cookie ("catch"-ing error response)
readybase.signIn().catch(function () {
  // Auth token invalid or not found
  showSignInForm();
});

// Authentication with email and password
readybase.signIn(emailInput.value, passwordInput.value).then(function (session) {
  // Secure cookie set automatically
  var currentUser = session.user;
});

// End session
readybase.signOut().then(function () {
  showMessage('You have successfully signed out.');
});
```

### Objects

In addtion to `id`, `data`, and `belongs_to`, all objects have a `type` attribute which must be a singular noun consisting only of lowercase letters and possibly the `_` character, e.g. `blog_post` or `team` or `message`. The API endpoints use the plural of `type` as the path.

For example, to create an object of type `message`, you would send parameters in a POST request to

```
/api/v1/messages
```

With JavaScript,

```js
var messageAttrs = {
  belongs_to: {
    sender: currentUser.id,
    recipient: someOtherUser.id
  },
  data: {
    content: 'Hello!'
  }
};

readybase.post('messages', messageAttrs).then(function (messageRecord) {
  ...
});
```

By default, the API accepts arbitrary data types. For example, all of the following are valid routes, by default.

```
/api/v1/snorkelfish
/api/v1/tyypos
/api/v1/sfdkgjsfdgj
```

However, you can configure your instance to only accept specific data types.

## Scope and Fields

You can specify the data you want the API to return using the parameters `scope` and `fields`, where `scope` limits which objects are returned and `fields` limits the attributes of those objects. These two options are also used when configuring access rules (see "Configuration" below).

### Scope

Scoping takes a query in readybase's scoping DSL, which is somewhat similar to SQL.

#### Examples

Get the `teams` that the current user `belongs_to`,

```js
var params = {
  scope: '@team where @self belongs_to @team',
  per_page: 20
};

readybase.get('teams', params).then(function (response) { ... });
```

### Fields

Get only the `id`, `title`, and `url` of the first 5 posts of `thisBlog`.

```js
var params = {
  fields: ['id','data.title','data.url'],
  per_page: 5
};
readybase.get(`blogs/${thisBlog.id}/posts`, params).then(function (response) {
  response.data; // [{id: 'o_123', data: {title: '...', url: '...'}}, {...}]
});
```

Get all the fields except `data.archive`.

```js
var params = {
  fields: ['*', '-data.archive']
}
...
```

## Configuration

You can configure user roles and access rules through `config/readybase_config.yml`. Access rules rely on `fields` and `scope` to define the restrictions for different user roles, object types, and actions (read, write, etc.).
